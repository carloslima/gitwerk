module View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Lazy exposing (lazy2)
import Route exposing (Route)
import Util exposing ((=>))
import User.UserData exposing (User, usernameToString)
import Material.Typography as Typo
import Material.Options as Options


type ActivePage
    = Other
    | Home
    | Login
    | Join


frame : Bool -> Maybe User -> ActivePage -> Html msg -> Html msg
frame isLoading user page content =
    div [ class "page-frame" ]
        [ viewHeader page user isLoading
        , content
        , viewFooter
        ]


viewHeader : ActivePage -> Maybe User -> Bool -> Html msg
viewHeader page user isLoading =
    case page of
        Login ->
            div []
                []

        Join ->
            div []
                []


        _ ->
            nav [ class "navbar navbar-toggleable-md navbar-light bg-faded" ]
                [ a [ class "navbar-brand", Route.href Route.Home ]
                    [ text "gitwerk" ]
                , div [ class "collapse navbar-collapse" ]
                    [ ul [ class "navbar-nav mr-auto" ] <|
                        lazy2 viewIf isLoading spinner
                            :: (navbarLink (page == Home) Route.Home [ text "Home" ])
                            :: viewSignIn page user
                    ]
                ]


viewSignIn : ActivePage -> Maybe User -> List (Html msg)
viewSignIn page user =
    case user of
        Nothing ->
            [ navbarLink (page == Login) Route.Login [ text "Login" ]
            , navbarLink (page == Join) Route.Join [ text "Join" ]
            ]

        Just user ->
            [ navbarLink True Route.UserSettingKey [ text ((usernameToString user.username) ++ " profile") ]
            , navbarLink True Route.NewRepository [ text ("Create Repo") ]
            , navbarLink True Route.Logout [ text "Sign out" ]
            ]


spinner : Html msg
spinner =
    li [ class "fa fa-spinner", style ([ "float" => "left", "margin" => "8px" ]) ]
        [ div [ class "glyphicon glyphicon-refresh" ] []
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
        [ Options.styled div
            [ Typo.body1
            ]
            [ a [ class "logo-font", href "/" ] [ text "gitwerk" ]
            , span [ class "attribution" ]
                [ text " is a web-based Git repository manager"
                ]
            ]
        ]
