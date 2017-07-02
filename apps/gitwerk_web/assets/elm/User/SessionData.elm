module User.SessionData exposing (..)

import User.UserData exposing (User, JWTAuthToken)
import HttpBuilder exposing (RequestBuilder, withHeader)


type alias Session =
    { user : Maybe User }


maybeAuthToken : Session -> Maybe JWTAuthToken
maybeAuthToken session =
    Maybe.map .token session.user


withAuthorization : Maybe JWTAuthToken -> RequestBuilder a -> RequestBuilder a
withAuthorization maybeToken builder =
    case maybeToken of
        Just (User.UserData.JWTAuthToken token) ->
            builder
                |> withHeader "authorization" ("Bearer " ++ token)

        Nothing ->
            builder
