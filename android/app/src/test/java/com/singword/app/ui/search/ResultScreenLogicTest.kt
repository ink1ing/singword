package com.singword.app.ui.search

import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class ResultScreenLogicTest {

    @Test
    fun retryShownOnlyForNetworkOrProviderErrors() {
        assertTrue(shouldShowRetry(SearchErrorCode.NETWORK_ERROR))
        assertTrue(shouldShowRetry(SearchErrorCode.PROVIDER_ERROR))

        assertFalse(shouldShowRetry(SearchErrorCode.NONE))
        assertFalse(shouldShowRetry(SearchErrorCode.EMPTY_QUERY))
        assertFalse(shouldShowRetry(SearchErrorCode.NO_WORDBOOK_SELECTED))
        assertFalse(shouldShowRetry(SearchErrorCode.WORDBOOK_MISSING_ASSET))
        assertFalse(shouldShowRetry(SearchErrorCode.WORDBOOK_PARSE_ERROR))
        assertFalse(shouldShowRetry(SearchErrorCode.LYRICS_NOT_FOUND))
        assertFalse(shouldShowRetry(SearchErrorCode.UNKNOWN))
    }
}
