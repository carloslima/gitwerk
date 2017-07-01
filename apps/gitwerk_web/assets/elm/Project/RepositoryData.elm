module Project.RepositoryData exposing (..)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipeline exposing (decode, required)
import Json.Encode as Encode exposing (Value)
import Util exposing ((=>))


type alias Repository =
    { id : String
    , name : String
    , namespace : String
    , privacy : String
    }


decoder : Decoder Repository
decoder =
    decode Repository
        |> required "id" Decode.string
        |> required "name" Decode.string
        |> required "namespace" Decode.string
        |> required "privacy" Decode.string
