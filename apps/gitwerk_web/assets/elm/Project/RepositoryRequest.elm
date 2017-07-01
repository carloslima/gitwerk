module Project.RepositoryRequest exposing (new)

import Http
import Json.Encode as Encode
import Json.Decode as Decode
import Util exposing ((=>))
import Project.RepositoryData as Repository exposing (Repository)


apiUrl end =
    "http://localhost:4000/api/v1/" ++ end


new : { r | namespace: String, name : String, privacy : String } -> Http.Request Repository
new { namespace, name, privacy } =
    let
        repo =
            Encode.object
                [ "name" => Encode.string name
                , "privacy" => Encode.string privacy
                ]

        body =
            Encode.object [ "repository" => repo ]
                |> Http.jsonBody
    in
        Repository.decoder
            |> Http.post (apiUrl (namespace ++ "/repository")) body
