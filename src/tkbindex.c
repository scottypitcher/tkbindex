/*
 * tkbindex.c --
 *
 * Extended bind command, taken from tk/generic/tkCmds.c
 *
 */

#include "tkInt.h"

#if defined(_WIN32)
#include "tkWinInt.h"
#elif defined(MAC_OSX_TK)
#include "tkMacOSXInt.h"
#else
#include "tkUnixInt.h"
#endif

#define PACKAGE_VERSION 1.1

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

    if ((objc < 2) || (objc > 4)) {
	Tcl_WrongNumArgs(interp, 1, objv, "window ?pattern? ?command?");
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
     * If there are four arguments, the command is modifying a binding. If
     * there are three arguments, the command is querying a binding. If there
     * are only two arguments, the command is querying all the bindings for
     * the given tag/window.
     */

    if (objc == 4) {
	int append = 0;
	unsigned long mask;
	const char *sequence = Tcl_GetString(objv[2]);
	const char *script = Tcl_GetString(objv[3]);

	/*
	 * If the script is null, just delete the binding.
	 */

	if (script[0] == 0) {
	    return Tk_DeleteBinding(interp, winPtr->mainPtr->bindingTable,
		    object, sequence);
	}

	/*
	 * If the script begins with "+", append this script to the existing
	 * binding.
	 */

	if (script[0] == '+') {
	    script++;
	    append = 1;
	}
	mask = Tk_CreateBinding(interp, winPtr->mainPtr->bindingTable,
		object, sequence, script, append);
	if (mask == 0) {
	    return TCL_ERROR;
	}
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
	Tk_GetAllBindings(interp, winPtr->mainPtr->bindingTable, object);
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
