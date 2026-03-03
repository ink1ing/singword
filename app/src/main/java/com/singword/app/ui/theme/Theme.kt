package com.singword.app.ui.theme

import androidx.compose.foundation.Indication
import androidx.compose.foundation.IndicationInstance
import androidx.compose.foundation.LocalIndication
import androidx.compose.foundation.interaction.InteractionSource
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.ui.graphics.drawscope.ContentDrawScope

private val LightColorScheme = lightColorScheme(
    primary = SingWordPalette.lightLink,
    onPrimary = SingWordPalette.lightTextPrimary,
    secondary = SingWordPalette.lightLink,
    tertiary = SingWordPalette.lightLink,
    background = SingWordPalette.lightBackground,
    surface = SingWordPalette.lightSurface,
    surfaceVariant = SingWordPalette.lightSurfaceVariant,
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
    surface = SingWordPalette.darkSurface,
    surfaceVariant = SingWordPalette.darkSurfaceVariant,
    onBackground = SingWordPalette.darkTextPrimary,
    onSurface = SingWordPalette.darkTextPrimaryAlt,
    onSurfaceVariant = SingWordPalette.darkTextSecondary,
    outline = SingWordPalette.darkCodeText,
    error = SingWordPalette.error
)

private object NoIndication : Indication {
    private object Instance : IndicationInstance {
        override fun ContentDrawScope.drawIndication() {
            drawContent()
        }
    }

    @Composable
    override fun rememberUpdatedInstance(interactionSource: InteractionSource): IndicationInstance {
        return Instance
    }
}

@Composable
fun SingWordTheme(
    themeMode: AppThemeMode,
    content: @Composable () -> Unit
) {
    val isDark = when (themeMode) {
        AppThemeMode.SYSTEM -> isSystemInDarkTheme()
        AppThemeMode.LIGHT -> false
        AppThemeMode.DARK -> true
    }
    val colorScheme = if (isDark) DarkColorScheme else LightColorScheme

    CompositionLocalProvider(
        LocalIndication provides NoIndication
    ) {
        MaterialTheme(
            colorScheme = colorScheme,
            typography = SingWordTypography,
            content = content
        )
    }
}
