/*
 * tkbindex.c --
 *
 * Extended bind command, taken from tk/generic/tkCmds.c
 *
 * Scott Pitcher 6SEP2021
 * This is a c implementation of the tkbindex extension.
 */

#include "tkInt.h"

#if defined(_WIN32)
#include "tkWinInt.h"
#elif defined(MAC_OSX_TK)
#include "tkMacOSXInt.h"
#else
#include "tkUnixInt.h"
#endif

#define PACKAGE_VERSION "1.1"

/*
 *----------------------------------------------------------------------
 *
 * Tk_BindObjCmd --
 *
 *	This function is invoked to process the "bind" Tcl command. See the
 *	user documentation for details on what it does.
 *
 * Results:
 *	A standard Tcl result.
 *
 * Side effects:
 *	See the user documentation.
 *
 *----------------------------------------------------------------------
 */

int
Tk_BindexObjCmd(
    ClientData clientData,	/* Main window associated with interpreter. */
    Tcl_Interp *interp,		/* Current interpreter. */
    int objc,			/* Number of arguments. */
    Tcl_Obj *const objv[])	/* Argument objects. */
{
    Tk_Window tkwin = clientData;
    TkWindow *winPtr;
    ClientData object;
    const char *string;

    if ((objc < 2) || (objc > 5)) {
	Tcl_WrongNumArgs(interp, 1, objv, "window ?pattern? ?command? ?command?");
	return TCL_ERROR;
    }
    string = Tcl_GetString(objv[1]);

    /*
     * Bind tags either a window name or a tag name for the first argument.
     * If the argument starts with ".", assume it is a window; otherwise, it
     * is a tag.
     */

    if (string[0] == '.') {
	winPtr = (TkWindow *) Tk_NameToWindow(interp, string, tkwin);
	if (winPtr == NULL) {
	    return TCL_ERROR;
	}
	object = (ClientData) winPtr->pathName;
    } else {
	winPtr = clientData;
	object = (ClientData) Tk_GetUid(string);
    }

    /*
     * If there are only two arguments, the command is querying all the bindings for
     * the given tag/window.
     * If there are three arguments, the command is querying a binding.
     * If there are four or five arguments, the command is modifying a binding.
     */

    if (objc == 2) {
	Tk_GetAllBindings(interp, winPtr->mainPtr->bindingTable, object);

    } else if (objc == 3) {
	const char *command;

	command = Tk_GetBinding(interp, winPtr->mainPtr->bindingTable,
		object, Tcl_GetString(objv[2]));
	if (command == NULL) {
	    Tcl_ResetResult(interp);
	    return TCL_OK;
	}
	Tcl_SetObjResult(interp, Tcl_NewStringObj(command, -1));

    } else {
	const char *append = 0, *replace = 0;
	unsigned long mask = 0;
	int result;
	const char *sequence = Tcl_GetString(objv[2]);
	const char *script = Tcl_GetString(objv[3]);
	const char *script2 = NULL;
	const char *cmd = NULL;
	int n1 = -1, n2 = -1, len1 = 0, len2 = 0;

	if (objc == 5) {
	    if (script[0] != '-') {
		Tcl_WrongNumArgs(interp, 1, objv, "window ?pattern? -?remove_command? ?append_command?");
		return TCL_ERROR;
	    }
	    script2 = Tcl_GetString(objv[4]);
	}

	/*
	 * Certain operators ('?', '*', and '-') require us to search the bind command for the
	 * matching script. We set the n1 and n2 indexes if we find it.
	 */

	if (script[0] == '?' || script[0] == '*' || script[0] == '-') {
	    const char *match;

	    cmd = Tk_GetBinding(interp, winPtr->mainPtr->bindingTable, object, sequence);
	    len1 = strlen(cmd);
	    len2 = strlen(script+1);

	    /*
	     * Look through the command for the script, either fully, or with a carriage return
	     * at either or both ends?
	     */
	    match = cmd;
	    while ((match = strstr(match, script + 1)) != NULL) {
		/*
		 * If the match is enclosed by start/end of string or newlines, then we have
		 * a valid match.
		 */
		if ((match == cmd || cmd[match-cmd-1] == '\n') && (match == cmd + len1 - len2 || match[len2] == '\n')) {
		    n1 = match - cmd;
		    n2 = n1 + len2 - 1;
		    break;
		}
		++match;
	    }
	}

	/*
	 * Now process the bind command.
	 */

	if (script[0] == '+') {
	    /*
	     * Append a command to the binding commands.
	     */
	    append = script+1;

	} else if (script[0] == '?') {
	    /*
	     * Query if a command is in the binding commands.
	     */
	    Tcl_AppendElement(interp, (n1 > -1 && n2 > -1) ? "1" : "0");

	} else if (script[0] == '-') {
	    /*
	     * Remove a command, and possibly add another one.
	     */
	    if (n1 > -1 && n2 > -1) {

		/*
		 * We cut the script out of the bind command.
		 */

		char *newcmd = Tcl_Alloc(len1+1);

		/* 
		 * Copy the first portion of cmd up to the character before the '\n' + script, then NUL terminate.
		 */
		newcmd[0] = '\0';
		if (n1 > 0) {
		    strncpy(newcmd,cmd,n1-1);
		    /* Remove trailing '\n' */
		    newcmd[n1-1] = '\0';
		}

		/*
		 * Append the trailing portion, and if there was a first portion, include the leading '\n'
		 */
		if (n2 < len1 - 1)
		    strcat(newcmd,cmd+n2+1+(n1 > 0 ? 0 : 1));

		if (newcmd[0] == '\0') {
		    if ((result = Tk_DeleteBinding(interp, winPtr->mainPtr->bindingTable, object, sequence)) != TCL_OK)
			return result;
		} else {
		    if ((mask = Tk_CreateBinding(interp, winPtr->mainPtr->bindingTable, object, sequence, newcmd, 0)) == 0)
			return TCL_ERROR;
		}
		Tcl_Free(newcmd);
		
		/*
		 * We only add the replacement command, if we found and removed the first one.
		 */
		append = script2;
		Tcl_AppendElement(interp, "1");

	    } else {
		Tcl_AppendElement(interp, "0");
	    }


	} else if (script[0] == '*') {
	    /*
	     * If the command was found then we return false, otherwise append it and return true.
	     */
	    if (n1 > -1 && n2 > -1) {
		Tcl_AppendElement(interp, "0");
	    } else {
		Tcl_AppendElement(interp, "1");
		append = script+1;
	    }

	} else if (script[0] == 0) {
	    /*
	     * If the script is empty, then remove it.
	     */
	    return Tk_DeleteBinding(interp, winPtr->mainPtr->bindingTable,
		    object, sequence);
	    
	} else {
	    /*
	     * The default case, replace the binding command
	     */
	    replace = script;
	}

		
	if (append) {
	    if ((mask = Tk_CreateBinding(interp, winPtr->mainPtr->bindingTable,
		    object, sequence, append, 1)) == 0)
		return TCL_ERROR;

	} else if (replace) {
	    if ((mask = Tk_CreateBinding(interp, winPtr->mainPtr->bindingTable,
		    object, sequence, script, 0)) == 0)
		return TCL_ERROR;
	}

    }
    return TCL_OK;
}


/* Init code. Startup and link our extension into Tcl.
 * This makes our new commands part of the tcl namespace so that our scripts can access it.
 */
int DLLEXPORT Bindex_Init(Tcl_Interp *interp)
{
    Tk_Window tkwin;

    if (Tcl_InitStubs (interp, TCL_VERSION, 0) == NULL)
	return TCL_ERROR;
    if (Tk_InitStubs (interp, TK_VERSION, 0) == NULL)
	return TCL_ERROR;

    if (Tcl_PkgProvide(interp, "bindex", PACKAGE_VERSION) == TCL_ERROR)
	return TCL_ERROR;

    if ((tkwin = Tk_MainWindow(interp)) == NULL)
	return TCL_ERROR;

    Tcl_CreateObjCommand(interp, "bindex", Tk_BindexObjCmd, (ClientData)tkwin, NULL);
    if (Tcl_IsSafe(interp))
	Tcl_HideCommand(interp, "bindex", "bindex");

    return TCL_OK;
}
