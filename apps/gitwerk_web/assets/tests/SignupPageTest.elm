module SignupPageTest exposing (..)

import Test exposing (..)
import Expect
import Http
import User.UserData as User exposing (User)
import User.SignupPage as SignupPage
import Dict
import Debug


anErrorMessage =
    """
{"errors": {"email": ["has already been taken"]}}
"""


apiUrl =
    "http://example.com/api/v1/users"


suite : Test
suite =
    describe "Handles API Signup error messages"
        [ test "handles 422 errors" <|
            \_ ->
                let
                    resp =
                        Http.Response apiUrl { code = 422, message = "Unprocessable Entity" } (Dict.fromList []) anErrorMessage

                    msg =
                        SignupPage.RegisterCompleted (Err (Http.BadStatus resp))

                    model =
                        (SignupPage.Model [] "" "" "")

                    update_result =
                        SignupPage.update msg model

                    expected_model =
                        (SignupPage.Model [ ( SignupPage.Form, "email has already been taken" ) ] "" "" "")
                in
                    Expect.equal update_result ( ( expected_model, Cmd.none ), SignupPage.NoOp )
        , test "handles other errors" <|
            \_ ->
                let
                    resp =
                        Http.Response apiUrl { code = 500, message = "Unprocessable Entity" } (Dict.fromList []) anErrorMessage

                    msg =
                        SignupPage.RegisterCompleted (Err (Http.BadStatus resp))

                    model =
                        (SignupPage.Model [] "" "" "")

                    update_result =
                        SignupPage.update msg model

                    expected_model =
                        (SignupPage.Model [ ( SignupPage.Form, "unable to process registration" ) ] "" "" "")
                in
                    Expect.equal update_result ( ( expected_model, Cmd.none ), SignupPage.NoOp )
        ]
