module HelpersRequestErrorsDataTest exposing (..)

import Test exposing (..)
import Expect
import Http
import User.UserData as User exposing (User)
import User.SignupPage as SignupPage
import Helpers.Request.ErrorsData as ErrorsData
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

                    error =
                        Http.BadStatus resp

                    expected_resonse =
                        ErrorsData.httpErrorToList2 "registration" error SignupPage.errorsDecoder
                in
                    Expect.equal expected_resonse (Dict.fromList [ ( "email", [ "email has already been taken" ] ), ( "password", [] ), ( "username", [] ) ])
        , test "handles other errors" <|
            \_ ->
                let
                    resp =
                        Http.Response apiUrl { code = 500, message = "Unprocessable Entity" } (Dict.fromList []) anErrorMessage

                    error =
                        Http.BadStatus resp

                    expected_resonse =
                        ErrorsData.httpErrorToList2 "registration" error SignupPage.errorsDecoder
                in
                    Expect.equal expected_resonse (Dict.fromList [ ( "default_error", [ "unable to process registration" ] ) ])
        ]
