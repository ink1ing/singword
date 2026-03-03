package com.singword.app.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable

private val SingWordColorScheme = lightColorScheme(
    primary = AccentGold,
    onPrimary = DeepBackground,
    secondary = AccentGoldDark,
    background = DarkBackground,
    surface = DarkSurface,
    surfaceVariant = DarkSurfaceVariant,
    onBackground = TextPrimary,
    onSurface = TextPrimary,
    onSurfaceVariant = TextSecondary,
    error = ErrorRed,
)

@Composable
fun SingWordTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = SingWordColorScheme,
        typography = SingWordTypography,
        content = content
    )
}
