module View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Lazy exposing (lazy2)
import Route exposing (Route)
import Util exposing ((=>))
import User.UserData exposing (User, usernameToString)
import Json.Encode as Json
import Gravatar


-- Bootstrap

import Bootstrap.CDN as CDN
import Bootstrap.Grid as Grid


type ActivePage
    = Other
    | Home
    | Login
    | Join


frame : Bool -> Maybe User -> ActivePage -> Html msg -> Html msg
frame isLoading user page content =
    div []
        [ CDN.stylesheet
        , viewHeader page user isLoading
        , Grid.container []
            [ content
            , viewFooter
            ]
        ]


gravatarHeaderOption : Gravatar.Options
gravatarHeaderOption =
    Gravatar.defaultOptions
        |> Gravatar.withSize (Just 20)
        |> Gravatar.withDefault Gravatar.Retro


viewHeader : ActivePage -> Maybe User -> Bool -> Html msg
viewHeader page user isLoading =
    let
        userEmail =
            case user of
                Nothing ->
                    ""

                Just user ->
                    user.email
    in
        case page of
            Login ->
                div []
                    []

            Join ->
                div []
                    []

            _ ->
                div
                    [ style
                        [ "background-color" => "#24292e"
                        , "color" => "#FFF"
                        ]
                    ]
                    [ Grid.container []
                        [ header [ class "navbar navbar-expand navbar-dark flex-column flex-md-row bd-navbar" ]
                            [ div [ class "navbar-nav-scroll" ]
                                [ ul [ class "navbar-nav bd-navbar-nav flex-row" ]
                                    [ lazy2 viewIf isLoading spinner
                                    , li [ class "nav-item" ]
                                        [ a [ class "nav-link ", Route.href Route.Home ]
                                            [ text "Gitwerk" ]
                                        ]
                                    ]
                                ]
                            , ul [ class "navbar-nav flex-row ml-md-auto d-none d-md-flex" ]
                                [ li [ class "nav-item dropdown" ]
                                    [ a
                                        [ class "nav-link dropdown-toggle"
                                        , href "#"
                                        , attribute "data-toggle" "dropdown"
                                        ]
                                        [ text "+" ]
                                    , div [ class "dropdown-menu" ]
                                        [ a
                                            [ class "dropdown-item"
                                            , Route.href Route.NewRepository
                                            ]
                                            [ text "Create Repo" ]
                                        ]
                                    ]
                                , li [ class "nav-item dropdown" ]
                                    [ a
                                        [ class "nav-link dropdown-toggle"
                                        , href "#"
                                        , attribute "data-toggle" "dropdown"
                                        ]
                                        [ Gravatar.img gravatarHeaderOption userEmail ]
                                    , div [ class "dropdown-menu" ]
                                        [ a
                                            [ class "dropdown-item"
                                            , Route.href Route.UserSettingKey
                                            ]
                                            [ text "Settings" ]
                                        , a [ class "divider" ] []
                                        , a
                                            [ class "dropdown-item"
                                            , Route.href Route.Logout
                                            ]
                                            [ text "Sign out" ]
                                        ]
                                    ]
                                ]
                            ]
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
        [ div []
            [ a [ class "logo-font", href "/" ] [ text "gitwerk" ]
            , span [ class "attribution" ]
                [ text " is a web-based Git repository manager"
                ]
            ]
        ]
