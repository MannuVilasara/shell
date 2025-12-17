import QtQuick

Item {
    id: root
    
    // Load dynamic colors from matugen-generated file
    MaterialColors { id: mat }
    
    // Main colors - mapped from Material Design colors
    readonly property color bg: mat.background
    readonly property color fg: mat.backgroundOn
    readonly property color muted: mat.outline
    readonly property color purple: mat.primary
    readonly property color blue: mat.secondary
    readonly property color green: mat.tertiary
    readonly property color red: mat.error
    readonly property color yellow: mat.tertiaryContainer
    readonly property color cyan: mat.secondaryContainer
    
    // Surface colors
    readonly property color surface: mat.surface
    readonly property color surfaceVariant: mat.surfaceVariant
    readonly property color border: mat.outlineVariant
}