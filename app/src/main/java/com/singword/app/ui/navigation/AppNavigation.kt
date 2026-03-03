package com.singword.app.ui.navigation

import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.outlined.FavoriteBorder
import androidx.compose.material.icons.outlined.Search
import androidx.compose.material.icons.outlined.Settings
import androidx.compose.material3.Icon
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.NavigationBarItemDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavDestination.Companion.hierarchy
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.singword.app.SingWordApp
import com.singword.app.ui.AppViewModelFactory
import com.singword.app.ui.favorites.FavoritesScreen
import com.singword.app.ui.favorites.FavoritesViewModel
import com.singword.app.ui.search.ResultScreen
import com.singword.app.ui.search.SearchScreen
import com.singword.app.ui.search.SearchViewModel
import com.singword.app.ui.search.SongCandidatesScreen
import com.singword.app.ui.settings.AboutSingWordScreen
import com.singword.app.ui.settings.SettingsScreen
import com.singword.app.ui.settings.SettingsViewModel
import com.singword.app.ui.theme.AccentGold
import com.singword.app.ui.theme.DarkSurface
import com.singword.app.ui.theme.TextTertiary

object AppRoute {
    const val Search = "search"
    const val Candidates = "candidates"
    const val Result = "result"
    const val Favorites = "favorites"
    const val Settings = "settings"
    const val About = "about"
}

sealed class NavTab(
    val route: String,
    val label: String,
    val selectedIcon: ImageVector,
    val unselectedIcon: ImageVector
) {
    data object Search : NavTab(AppRoute.Search, "搜索", Icons.Filled.Search, Icons.Outlined.Search)
    data object Favorites : NavTab(
        AppRoute.Favorites,
        "收藏",
        Icons.Filled.Favorite,
        Icons.Outlined.FavoriteBorder
    )
    data object Settings : NavTab(AppRoute.Settings, "设置", Icons.Filled.Settings, Icons.Outlined.Settings)
}

private val navTabs = listOf(NavTab.Search, NavTab.Favorites, NavTab.Settings)

@Composable
fun AppNavigation() {
    val navController = rememberNavController()
    val context = LocalContext.current.applicationContext as SingWordApp
    val factory = remember(context) { AppViewModelFactory(context.container) }
    val searchViewModel: SearchViewModel = viewModel(factory = factory)
    val favoritesViewModel: FavoritesViewModel = viewModel(factory = factory)
    val settingsViewModel: SettingsViewModel = viewModel(factory = factory)
    val searchUiState by searchViewModel.uiState.collectAsState()
    val favoriteWords by searchViewModel.favoriteWords.collectAsState()

    val navBackStackEntry by navController.currentBackStackEntryAsState()
    val currentDestination = navBackStackEntry?.destination
    val showBottomBar = currentDestination?.route != AppRoute.Result &&
        currentDestination?.route != AppRoute.Candidates &&
        currentDestination?.route != AppRoute.About

    Scaffold(
        bottomBar = {
            if (showBottomBar) {
                NavigationBar(containerColor = DarkSurface) {
                    navTabs.forEach { tab ->
                        val selected = currentDestination?.hierarchy?.any { it.route == tab.route } == true
                        NavigationBarItem(
                            selected = selected,
                            onClick = {
                                navController.navigate(tab.route) {
                                    popUpTo(navController.graph.findStartDestination().id) {
                                        saveState = true
                                    }
                                    launchSingleTop = true
                                    restoreState = true
                                }
                            },
                            icon = {
                                Icon(
                                    if (selected) tab.selectedIcon else tab.unselectedIcon,
                                    contentDescription = tab.label
                                )
                            },
                            label = { Text(tab.label) },
                            colors = NavigationBarItemDefaults.colors(
                                selectedIconColor = AccentGold,
                                selectedTextColor = AccentGold,
                                unselectedIconColor = TextTertiary,
                                unselectedTextColor = TextTertiary,
                                indicatorColor = AccentGold.copy(alpha = 0.12f)
                            )
                        )
                    }
                }
            }
        }
    ) { innerPadding ->
        NavHost(
            navController = navController,
            startDestination = AppRoute.Search,
            modifier = Modifier.padding(innerPadding)
        ) {
            composable(AppRoute.Search) {
                SearchScreen(
                    query = searchUiState.query,
                    error = searchUiState.error,
                    onQueryChange = {
                        searchViewModel.onQueryChanged(it)
                        searchViewModel.clearError()
                    },
                    onSubmit = {
                        if (searchViewModel.searchCandidates()) {
                            navController.navigate(AppRoute.Candidates)
                        }
                    }
                )
            }
            composable(AppRoute.Candidates) {
                SongCandidatesScreen(
                    uiState = searchUiState,
                    onBack = { navController.popBackStack() },
                    onRetry = { searchViewModel.searchCandidates() },
                    onSelect = { candidate ->
                        searchViewModel.selectCandidate(candidate)
                        navController.navigate(AppRoute.Result)
                    }
                )
            }
            composable(AppRoute.Result) {
                ResultScreen(
                    uiState = searchUiState,
                    favorites = favoriteWords,
                    onToggleFavorite = searchViewModel::toggleFavorite,
                    onBack = { navController.popBackStack() },
                    onRetry = searchViewModel::retryResult
                )
            }
            composable(AppRoute.Favorites) {
                FavoritesScreen(viewModel = favoritesViewModel)
            }
            composable(AppRoute.Settings) {
                SettingsScreen(
                    viewModel = settingsViewModel,
                    onOpenAbout = { navController.navigate(AppRoute.About) }
                )
            }
            composable(AppRoute.About) {
                AboutSingWordScreen(
                    onBack = { navController.popBackStack() }
                )
            }
        }
    }
}
