package com.singword.app.ui.search

import androidx.compose.runtime.mutableStateOf
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.performClick
import com.singword.app.test.EmulatorOnly
import org.junit.Assert.assertEquals
import org.junit.Rule
import org.junit.Test

@EmulatorOnly
class SearchScreenTest {
    @get:Rule
    val composeRule = createComposeRule()

    @Test
    fun submitUsesLatestQuery() {
        val query = mutableStateOf("Shape of You")
        var submitted = ""

        composeRule.setContent {
            SearchScreen(
                query = query.value,
                error = null,
                onQueryChange = { query.value = it },
                onSubmit = { submitted = query.value }
            )
        }

        composeRule.onNodeWithTag("search_input").assertIsDisplayed()
        composeRule.onNodeWithTag("search_button").performClick()

        assertEquals("Shape of You", submitted)
    }
}
