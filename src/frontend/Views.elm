module Views exposing (..)

import Html exposing (..)
import Types exposing (..)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (type_, value, placeholder, class, id, selected)
import Json.Decode
import Date


ownerTableRow : Model -> String -> Html Msg
ownerTableRow model owner =
    let
        ownerCount =
            List.filter (\disc -> disc.owner == owner) model.discs
                |> List.length
    in
        tr []
            [ td [] [ text owner ]
            , td [] [ text (toString ownerCount) ]
            ]


discCard : Disc -> Html Msg
discCard disc =
    let
        statusClass =
            if disc.completed then
                "completeCard"
            else
                "pendingCard"
    in
        div [ class ("card " ++ statusClass), onClick (Edit disc) ]
            [ div [ class "bar" ]
                [ span [ class "owner" ] [ text disc.owner ]
                , span [ class "date" ] [ text (prettyDate (disc.date * 1000)) ]
                ]
            , span [ class "title" ] [ text disc.title ]
            ]


prettyDate : Int -> String
prettyDate dateInt =
    let
        date =
            dateInt |> toFloat |> Date.fromTime

        yearStr =
            date |> Date.year |> toString

        monthStr =
            date |> Date.month |> toString

        dayStr =
            date |> Date.day |> toString
    in
        yearStr ++ "-" ++ monthStr ++ "-" ++ dayStr


discCardList : Model -> Html Msg
discCardList model =
    let
        list =
            model.discs
                |> List.sortBy (\disc -> disc.date * -1)
                |> List.filter (\disc -> filterMatch model.filterText disc.title)
    in
        div []
            (List.map
                discCard
                list
            )


filterField : Model -> Html Msg
filterField model =
    div []
        [ input
            [ type_ "text"
            , id "titleFilter"
            , value model.filterText
            , placeholder "Filter titles"
            , onInput FilterTitle
            ]
            []
        ]


filterMatch : String -> String -> Bool
filterMatch x y =
    String.contains (String.toLower x) (String.toLower y)


formatSelector : Disc -> Html Msg
formatSelector disc =
    let
        formats =
            [ "DVD-Video", "Data DVD", "CD", "Game" ]
    in
        select
            [ onInput (UpdatePending << Format), placeholder "Format" ]
            (List.map
                (\x ->
                    option
                        [ value x
                        , selected (x == disc.format)
                        ]
                        [ text x ]
                )
                formats
            )


link : String -> Html Msg
link name =
    li []
        [ a [ Html.Attributes.href ("#" ++ name) ]
            [ text name ]
        ]


onChange : (String -> msg) -> Attribute msg
onChange handler =
    Html.Events.on "change" <|
        Json.Decode.map handler <|
            Json.Decode.at [ "target", "value" ] Json.Decode.string


navbar : Model -> Html Msg
navbar model =
    nav []
        [ span [ Html.Attributes.class "count" ]
            [ text ((model.discs |> List.length |> toString) ++ " discs") ]
        , ul []
            [ link "list", link "insert", link "stats" ]
        ]


homepage : Model -> Html Msg
homepage model =
    div []
        [ navbar model
        , h1 [] [ text model.error ]
        , filterField model
          --, discDisplay model
        , discCardList model
        ]


insertPage : Model -> Html Msg
insertPage model =
    div []
        [ navbar model
        , div
            [ class "form" ]
            [ label []
                [ text "Title"
                , input
                    [ type_ "text"
                    , value model.pending.title
                    , onInput (UpdatePending << Title)
                    ]
                    []
                ]
            , label []
                [ text "Owner"
                , input
                    [ type_ "text"
                    , value model.pending.owner
                    , onInput (UpdatePending << Owner)
                    ]
                    []
                ]
            , formatSelector model.pending
            , button [ onClick InsertSignal ] [ text "Insert" ]
            ]
        ]


statspage : Model -> Html Msg
statspage model =
    div []
        [ navbar model
        , table []
            [ thead []
                [ th []
                    [ td [] [ text "Person" ]
                    , td [] [ text "Discs" ]
                    ]
                ]
            , tbody [] (List.map (ownerTableRow model) model.owners)
            ]
        ]


completionToggle : Disc -> Html Msg
completionToggle disc =
    let
        displayText =
            if disc.completed then
                "Completed"
            else
                "Pending"
    in
        button
            [ onClick (UpdatePending Completed)
            , class
                (if disc.completed then
                    "completeDisc"
                 else
                    "pendingDisc"
                )
            ]
            [ text displayText ]


editPage : Model -> Html Msg
editPage model =
    div []
        [ navbar model
        , div
            [ class "form" ]
            [ label []
                [ text "ID"
                , input
                    [ type_ "text"
                    , Html.Attributes.readonly True
                    , value (toString model.pending.id)
                    ]
                    []
                ]
            , label []
                [ text "Title"
                , input
                    [ type_ "text"
                    , value model.pending.title
                    , onInput (UpdatePending << Title)
                    ]
                    []
                ]
            , label []
                [ text "Owner"
                , input
                    [ type_ "text"
                    , value model.pending.owner
                    , onInput (UpdatePending << Owner)
                    ]
                    []
                ]
            , formatSelector model.pending
            , completionToggle model.pending
            , button
                [ id "deleteButton"
                , onClick DeleteSignal
                ]
                [ text "Delete" ]
            , button
                [ id "editButton"
                , onClick EditSignal
                ]
                [ text "Edit" ]
            ]
        ]


pages : Model -> String -> Html Msg
pages model page =
    case page of
        "#insert" ->
            insertPage model

        "#stats" ->
            statspage model

        "#list" ->
            homepage model

        "#edit" ->
            editPage model

        _ ->
            homepage model


mainView : Model -> Html Msg
mainView model =
    case (List.head model.history) of
        Nothing ->
            homepage model

        Just location ->
            pages model (location.hash)
