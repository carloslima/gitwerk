module Project.FileData exposing (..)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipeline exposing (decode, required)
import Json.Encode as Encode exposing (Value)
import Util exposing ((=>))


type alias File =
    { file_type : String
    , name : String
    }


decoder : Decoder File
decoder =
    decode File
        |> required "type" Decode.string
        |> required "name" Decode.string
