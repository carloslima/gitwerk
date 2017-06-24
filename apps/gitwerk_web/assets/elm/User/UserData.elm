module User.UserData exposing (..)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipeline exposing (decode, required)
import Json.Encode as Encode exposing (Value)
import Util exposing ((=>))



type alias User =
    { email : String
    , token : JWTAuthToken
    , username : Username
    }


type Username
    = Username String


type JWTAuthToken
    = JWTAuthToken String


authTokenDecoder : Decoder JWTAuthToken
authTokenDecoder =
    Decode.string
        |> Decode.map JWTAuthToken


decoder : Decoder User
decoder =
    decode User
        |> required "email" Decode.string
        |> required "jwt_token" authTokenDecoder
        |> required "username" usernameDecoder


usernameDecoder : Decoder Username
usernameDecoder =
    Decode.map Username Decode.string


decodeUserFromJson : Value -> Maybe User
decodeUserFromJson json =
    json
        |> Decode.decodeValue Decode.string
        |> Result.toMaybe
        |> Maybe.andThen (Decode.decodeString decoder >> Result.toMaybe)

encode : User -> Value
encode user =
    Encode.object
        [ "email" => Encode.string user.email
        , "jwt_token" => encodeJWTAuthtoken user.token
        , "username" => encodeUsername user.username
        ]

encodeUsername : Username -> Value
encodeUsername (Username username) =
    Encode.string username

encodeJWTAuthtoken : JWTAuthToken -> Value
encodeJWTAuthtoken (JWTAuthToken token) =
    Encode.string token

usernameToString : Username -> String
usernameToString (Username username) =
        username
