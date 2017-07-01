module Helpers.Views.Form exposing (viewErrors, input, select, textarea, password, radio, fieldset)

import Html exposing (fieldset, ul, li, Html, Attribute, text, select)
import Html.Attributes exposing (class, type_)


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
    control Html.select ([ ] ++ attrs)

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



-- INTERNAL --


control :
    (List (Attribute msg) -> List (Html msg) -> Html msg)
    -> List (Attribute msg)
    -> List (Html msg)
    -> Html msg
control element attributes children =
    Html.fieldset [ class "form-group" ]
        [ element (class "form-control" :: attributes) children ]
