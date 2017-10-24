module Helpers.Views.Form exposing (viewErrors, input, select, textarea, password, radio, fieldset, anyDefaultError, getErrorFor, validationTextIfAny, showDefaultErrorIfAny)

import Html exposing (fieldset, ul, li, Html, Attribute, text, select)
import Html.Attributes exposing (class, type_)
import Dict exposing (Dict)


-- Bootstrap

import Bootstrap.Form as BForm
import Bootstrap.Alert as BAlert


password : List (Attribute msg) -> List (Html msg) -> Html msg
password attrs =
    control Html.input ([ type_ "password" ] ++ attrs)


input : List (Attribute msg) -> List (Html msg) -> Html msg
input attrs =
    control Html.input ([ type_ "text" ] ++ attrs)


radio : List (Attribute msg) -> List (Html msg) -> Html msg
radio attrs =
    Html.input ([ type_ "radio" ] ++ attrs)


select : List (Attribute msg) -> List (Html msg) -> Html msg
select attrs =
    control Html.select ([] ++ attrs)


textarea : List (Attribute msg) -> List (Html msg) -> Html msg
textarea =
    control Html.textarea


fieldset : List (Attribute msg) -> List (Html msg) -> Html msg
fieldset attributes children =
    control Html.fieldset attributes children


viewErrors : List ( a, String ) -> Html msg
viewErrors errors =
    errors
        |> List.map (\( _, error ) -> li [] [ text error ])
        |> ul [ class "error-messages" ]


anyDefaultError : String -> Dict String (List String) -> Maybe String
anyDefaultError field errors =
    case Dict.get "default_error" errors of
        Nothing ->
            Nothing

        Just errs ->
            List.head errs


getErrorFor : String -> Dict String (List String) -> Maybe String
getErrorFor field errors =
    case Dict.get field errors of
        Nothing ->
            Nothing

        Just errs ->
            List.head errs


validationTextIfAny : String -> Dict String (List String) -> Html msg
validationTextIfAny field errors =
    case getErrorFor field errors of
        Nothing ->
            text ""

        Just err ->
            BForm.validationText [] [ text err ]


showDefaultErrorIfAny : Dict String (List String) -> Html msg
showDefaultErrorIfAny errors =
    case getErrorFor "default_error" errors of
        Nothing ->
            text ""

        Just err ->
            BAlert.danger [ text err ]



-- INTERNAL --


control :
    (List (Attribute msg) -> List (Html msg) -> Html msg)
    -> List (Attribute msg)
    -> List (Html msg)
    -> Html msg
control element attributes children =
    Html.fieldset []
        [ element (attributes) children ]