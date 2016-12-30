module Network exposing (..)

import Http
import Types exposing (..)
import Json.Decode exposing (..)
import Json.Encode


discEncoder : Disc -> Json.Encode.Value
discEncoder disc =
    Json.Encode.object
        [ ( "owner", Json.Encode.string disc.owner )
        , ( "title", Json.Encode.string disc.title )
        , ( "format", Json.Encode.string disc.format )
        , ( "id", Json.Encode.int disc.id )
        , ( "completed"
          , Json.Encode.string
                (disc.completed
                    |> toString
                    |> String.toLower
                )
          )
        , ( "date", Json.Encode.int disc.date )
        ]


insertAction : Disc -> Cmd Msg
insertAction disc =
    Http.post "/discs/insert" (Http.jsonBody (discEncoder disc)) int
        |> Http.send InsertPending


deleteAction : Disc -> Cmd Msg
deleteAction disc =
    Http.post "/discs/delete" (Http.jsonBody (discEncoder disc)) int
        |> Http.send DeletePending


editAction : Disc -> Cmd Msg
editAction disc =
    Http.post "/discs/edit" (Http.jsonBody (discEncoder disc)) int
        |> Http.send EditPending


discDecoder : Decoder Disc
discDecoder =
    map6 Disc
        (field "owner" string)
        (field "title" string)
        (field "format" string)
        (field "id" int)
        (field "completed" intBoolDecoder)
        (field "date" int)


discListDecoder : Decoder (List Disc)
discListDecoder =
    list discDecoder


getDiscs : Cmd Msg
getDiscs =
    Http.get "/discs/list" discListDecoder
        |> Http.send JsonResponse


intBoolDecoder : Json.Decode.Decoder Bool
intBoolDecoder =
    let
        convert value =
            case value of
                0 ->
                    False

                1 ->
                    True

                otherwise ->
                    Debug.crash "value was not 0 or 1"
    in
        Json.Decode.map convert int
