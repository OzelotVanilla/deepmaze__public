class_name DMFSResult
extends RefCounted
## FS Operation Rust-like-style [code]Result[/code].


## Represents the error used in [DMFSResult].
enum Error
{
    ## Default value, no error occured.
    ok,
    ## Path is invalid (e.g., empty or mal-formed).
    path_invalid,
    ## Required file/folder not found.
    not_found,
    ## Required part is not a file.
    not_file,
    ## Required part is not a folder.
    not_folder,
    ## The required file/folder already exists.
    already_exists,
    ## The required operation does not have enough permission level and it is denied.
    permission_denied,
    ## The required operation is not allowed by system.
    operation_not_allowed
}


## Type of error.
var error: DMFSResult.Error

## Additional message for the result.
## Useful for storing message to print.
var message: String

## Value of the result.[br][br]
##
## Only available if this result [member is_ok].
## Raise an assertion error if debugging.
var value: Variant = null:
    get():
        assert(self.is_ok, "Cannot get `DMFSResult.value` from a error result.")
        return value

## Current result is an error result.
var is_error: bool:
    get():
        return self.error != DMFSResult.Error.ok

## Current result is a correct result.
var is_ok: bool:
    get():
        return self.error == DMFSResult.Error.ok


## Create a new OK-typed result with a value.
static func createOK(
    ok_value: Variant = null, ok_message: String = ""
) -> DMFSResult:
    var result := DMFSResult.new()
    result.error   = DMFSResult.Error.ok
    result.message = ok_message
    result.value   = ok_value

    return result

## Create a new Error-typed result with the error type.
static func createError(
    error_type: DMFSResult.Error, error_message: String = ""
) -> DMFSResult:
    var result := DMFSResult.new()
    result.error   = error_type
    result.message = error_message
    result.value   = null

    return result
