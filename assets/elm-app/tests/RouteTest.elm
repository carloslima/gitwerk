module RouteTest exposing (..)

import Test exposing (..)
import Expect
import Route as Route exposing (Route, href)
import Html.Attributes


suite : Test
suite =
    describe "parse routes"
        [ test "Home route" <|
            \_ ->
                Expect.equal (Html.Attributes.href "#/") (Route.href Route.Home)
        , test "Join route" <|
            \_ ->
                Expect.equal (Html.Attributes.href "#/join") (Route.href Route.Join)
        , test "Login route" <|
            \_ ->
                Expect.equal (Html.Attributes.href "#/login") (Route.href Route.Login)
        , test "create repo" <|
            \_ ->
                Expect.equal (Html.Attributes.href "#/repo") (Route.href Route.NewRepository)
        , test "repo route" <|
            \_ ->
                Expect.equal (Html.Attributes.href "#/foo/bar") (Route.href (Route.ShowRepository "foo" "bar"))
        , test "user profile key" <|
            \_ ->
                Expect.equal (Html.Attributes.href "#/settings/keys") (Route.href Route.UserSettingKey)
        ]
