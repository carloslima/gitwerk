module Route exposing (Route(..), href, modifyUrl, fromLocation)

import UrlParser2 as Url exposing (parseHash, s, (</>), string, wildcard, (</*>), oneOf, Parser)
import Navigation exposing (Location)
import Html exposing (Attribute)
import Html.Attributes as Attr
import Debug


type Route
    = Home
    | Login
    | Join
    | Logout
    | NewRepository
    | ShowRepository String String
    | ShowRepositoryTree String String String (List String)
    | UserSettingKey


route : Parser (Route -> a) a
route =
    oneOf
        [ Url.map Home (s "")
        , Url.map Login (s "login")
        , Url.map Join (s "join")
        , Url.map Logout (s "logout")
        , Url.map NewRepository (s "repo")
        , Url.map UserSettingKey (s "settings" </> s "keys")
        , Url.map ShowRepository (string </> string)
        , Url.map ShowRepositoryTree (string </> string </> s "tree" </> string </> wildcard)
        ]


routeToString : Route -> String
routeToString page =
    let
        pieces =
            case page of
                Home ->
                    []

                Login ->
                    [ "login" ]

                Join ->
                    [ "join" ]

                Logout ->
                    [ "logout" ]

                NewRepository ->
                    [ "repo" ]

                ShowRepository namespace repo ->
                    [ namespace, repo ]

                ShowRepositoryTree namespace repo tree rest ->
                    List.append [ namespace, repo, "tree", tree ] rest

                UserSettingKey ->
                    [ "settings", "keys" ]
    in
        "#/" ++ (String.join "/" pieces)



-- PUBLIC HELPERS --


href : Route -> Attribute msg
href route =
    Attr.href (routeToString route)


modifyUrl : Route -> Cmd msg
modifyUrl =
    routeToString >> Navigation.modifyUrl


fromLocation : Location -> Maybe Route
fromLocation location =
    if String.isEmpty location.hash then
        Just Home
    else
        parseHash route location
