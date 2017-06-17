module View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Lazy exposing (lazy2)
import Route exposing (Route)
import Util exposing ((=>))


type ActivePage
    = Other
    | Home
    | Login
    | Join


frame : ActivePage -> Html msg -> Html msg
frame page contect =
    div [ class "page-frame" ]
        [ viewHeader page
        , contect
        , viewFooter
        ]


viewHeader : ActivePage -> Html msg
viewHeader page =
    nav [ class "navbar navbar-toggleable-md navbar-light bg-faded" ]
        [ a [ class "navbar-brand", Route.href Route.Home ]
            [ text "gitwerk" ]
        , div [ class "collapse navbar-collapse" ]
            [ ul [ class "navbar-nav mr-auto" ] <|
                lazy2 viewIf False spinner
                    :: (navbarLink (page == Home) Route.Home [ text "Home" ])
                    :: viewSignIn page
            ]
        ]


viewSignIn : ActivePage -> List (Html msg)
viewSignIn page =
    [ navbarLink (page == Login) Route.Login [ text "Sign in" ]
    , navbarLink (page == Join) Route.Join [ text "Sign up" ]
    ]


spinner : Html msg
spinner =
    li [ class "sk-three-bounce", style ([ "float" => "left", "margin" => "8px" ]) ]
        [ div [ class "sk-child sk-bounce1" ] []
        , div [ class "sk-child sk-bounce2" ] []
        , div [ class "sk-child sk-bounce3" ] []
        ]


viewIf : Bool -> Html msg -> Html msg
viewIf condition content =
    if condition then
        content
    else
        Html.text ""


navbarLink : Bool -> Route -> List (Html msg) -> Html msg
navbarLink isActive route linkContent =
    li [ classList [ ( "nav-item", True ), ( "active", isActive ) ] ]
        [ a [ class "nav-link", Route.href route ] linkContent ]


viewFooter : Html msg
viewFooter =
    footer []
        [ div [ class "container" ]
            [ a [ class "logo-font", href "/" ] [ text "gitwerk" ]
            , span [ class "attribution" ]
                [ text " is a web-based Git repository manager"
                ]
            ]
        ]
