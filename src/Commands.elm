module Commands exposing (..)

import Http
import Json.Decode
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode
import Models exposing (Player, PlayerId)
import Msgs exposing (Msg)
import RemoteData


fetchPlayers : Cmd Msg
fetchPlayers =
    Http.get fetchPlayersUrl playersDecoder
        |> RemoteData.sendRequest
        |> Cmd.map Msgs.OnFetchPlayers


fetchPlayersUrl : String
fetchPlayersUrl =
    "http://localhost:3000/players"


playersDecoder : Json.Decode.Decoder (List Player)
playersDecoder =
    Json.Decode.list playerDecoder


playerDecoder : Json.Decode.Decoder Player
playerDecoder =
    decode Player
        |> required "id" Json.Decode.string
        |> required "name" Json.Decode.string
        |> required "level" Json.Decode.int


savePlayerUrl : PlayerId -> String
savePlayerUrl playerId =
    "http://localhost:3000/players/" ++ playerId


savePlayerRequest : Player -> Http.Request Player
savePlayerRequest player =
    Http.request
        { body = playerEncoder player |> Http.jsonBody
        , expect = Http.expectJson playerDecoder
        , headers = []
        , method = "PATCH"
        , timeout = Nothing
        , url = savePlayerUrl player.id
        , withCredentials = False
        }


savePlayerCmd : Player -> Cmd Msg
savePlayerCmd player =
    savePlayerRequest player
        |> Http.send Msgs.OnPlayerSave


playerEncoder : Player -> Json.Encode.Value
playerEncoder player =
    let
        attributes =
            [ ( "id", Json.Encode.string player.id )
            , ( "name", Json.Encode.string player.name )
            , ( "level", Json.Encode.int player.level )
            ]
    in
        Json.Encode.object attributes
