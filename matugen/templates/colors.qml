import QtQuick

QtObject {
    id: materialColors

    // Primary colors
    readonly property color primary: "{{colors.primary.dark.hex}}"
    readonly property color primaryOn: "{{colors.on_primary.dark.hex}}"
    readonly property color primaryContainer: "{{colors.primary_container.dark.hex}}"
    readonly property color primaryContainerOn: "{{colors.on_primary_container.dark.hex}}"

    // Secondary colors
    readonly property color secondary: "{{colors.secondary.dark.hex}}"
    readonly property color secondaryOn: "{{colors.on_secondary.dark.hex}}"
    readonly property color secondaryContainer: "{{colors.secondary_container.dark.hex}}"
    readonly property color secondaryContainerOn: "{{colors.on_secondary_container.dark.hex}}"

    // Tertiary colors
    readonly property color tertiary: "{{colors.tertiary.dark.hex}}"
    readonly property color tertiaryOn: "{{colors.on_tertiary.dark.hex}}"
    readonly property color tertiaryContainer: "{{colors.tertiary_container.dark.hex}}"
    readonly property color tertiaryContainerOn: "{{colors.on_tertiary_container.dark.hex}}"

    // Error colors
    readonly property color error: "{{colors.error.dark.hex}}"
    readonly property color errorOn: "{{colors.on_error.dark.hex}}"
    readonly property color errorContainer: "{{colors.error_container.dark.hex}}"
    readonly property color errorContainerOn: "{{colors.on_error_container.dark.hex}}"

    // Background and Surface
    readonly property color background: "{{colors.background.dark.hex}}"
    readonly property color backgroundOn: "{{colors.on_background.dark.hex}}"
    readonly property color surface: "{{colors.surface.dark.hex}}"
    readonly property color surfaceOn: "{{colors.on_surface.dark.hex}}"
    readonly property color surfaceVariant: "{{colors.surface_variant.dark.hex}}"
    readonly property color surfaceVariantOn: "{{colors.on_surface_variant.dark.hex}}"

    // Outline
    readonly property color outline: "{{colors.outline.dark.hex}}"
    readonly property color outlineVariant: "{{colors.outline_variant.dark.hex}}"
}
