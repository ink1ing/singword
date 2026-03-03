package com.singword.app.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable

private val LightColorScheme = lightColorScheme(
    primary = SingWordPalette.lightLink,
    onPrimary = SingWordPalette.lightTextPrimary,
    secondary = SingWordPalette.lightLink,
    tertiary = SingWordPalette.lightLink,
    background = SingWordPalette.lightBackground,
    surface = androidx.compose.ui.graphics.Color.White,
    surfaceVariant = androidx.compose.ui.graphics.Color(0xFFEDE5DD),
    onBackground = SingWordPalette.lightTextPrimary,
    onSurface = SingWordPalette.lightTextPrimaryAlt,
    onSurfaceVariant = SingWordPalette.lightTextSecondary,
    outline = SingWordPalette.lightCodeText,
    error = SingWordPalette.error
)

private val DarkColorScheme = darkColorScheme(
    primary = SingWordPalette.darkLink,
    onPrimary = SingWordPalette.darkTextPrimary,
    secondary = SingWordPalette.darkLink,
    tertiary = SingWordPalette.darkLink,
    background = SingWordPalette.darkBackground,
    surface = androidx.compose.ui.graphics.Color(0xFF242320),
    surfaceVariant = androidx.compose.ui.graphics.Color(0xFF2E2D2A),
    onBackground = SingWordPalette.darkTextPrimary,
    onSurface = SingWordPalette.darkTextPrimaryAlt,
    onSurfaceVariant = SingWordPalette.darkTextSecondary,
    outline = SingWordPalette.darkCodeText,
    error = SingWordPalette.error
)

@Composable
fun SingWordTheme(
    themeMode: AppThemeMode,
    content: @Composable () -> Unit
) {
    val colorScheme = when (themeMode) {
        AppThemeMode.LIGHT -> LightColorScheme
        AppThemeMode.DARK -> DarkColorScheme
    }

    MaterialTheme(
        colorScheme = colorScheme,
        typography = SingWordTypography,
        content = content
    )
}
