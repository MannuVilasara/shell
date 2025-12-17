import QtQuick

QtObject {
    id: materialColors

    // Primary colors
    readonly property color primary: "#ffb68d"
    readonly property color primaryOn: "#532200"
    readonly property color primaryContainer: "#6f3813"
    readonly property color primaryContainerOn: "#ffdbc9"

    // Secondary colors
    readonly property color secondary: "#e6beaa"
    readonly property color secondaryOn: "#432b1d"
    readonly property color secondaryContainer: "#5c4131"
    readonly property color secondaryContainerOn: "#ffdbc9"

    // Tertiary colors
    readonly property color tertiary: "#cdc991"
    readonly property color tertiaryOn: "#343208"
    readonly property color tertiaryContainer: "#4a481d"
    readonly property color tertiaryContainerOn: "#e9e5ab"

    // Error colors
    readonly property color error: "#ffb4ab"
    readonly property color errorOn: "#690005"
    readonly property color errorContainer: "#93000a"
    readonly property color errorContainerOn: "#ffdad6"

    // Background and Surface
    readonly property color background: "#1a120d"
    readonly property color backgroundOn: "#f0dfd7"
    readonly property color surface: "#1a120d"
    readonly property color surfaceOn: "#f0dfd7"
    readonly property color surfaceVariant: "#52443c"
    readonly property color surfaceVariantOn: "#d7c2b8"

    // Outline
    readonly property color outline: "#9f8d84"
    readonly property color outlineVariant: "#52443c"
}
