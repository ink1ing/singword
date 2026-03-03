package com.singword.app.ui.settings

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.singword.app.data.local.wordbook.WordbookId
import com.singword.app.ui.theme.AccentGold
import com.singword.app.ui.theme.DarkCard
import com.singword.app.ui.theme.DarkSurfaceVariant
import com.singword.app.ui.theme.TextSecondary
import com.singword.app.ui.theme.TextTertiary

@Composable
fun SettingsScreen(
    viewModel: SettingsViewModel,
    onOpenAbout: () -> Unit
) {
    val uiState by viewModel.uiState.collectAsState()
    val selection = uiState.selection

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
            .padding(horizontal = 16.dp)
    ) {
        Spacer(modifier = Modifier.height(16.dp))

        Row(verticalAlignment = Alignment.CenterVertically) {
            Icon(
                Icons.Default.Settings,
                contentDescription = null,
                tint = AccentGold,
                modifier = Modifier.size(24.dp)
            )
            Spacer(modifier = Modifier.width(8.dp))
            Text(
                text = "设置",
                style = MaterialTheme.typography.headlineLarge,
                color = MaterialTheme.colorScheme.onBackground
            )
        }

        Spacer(modifier = Modifier.height(24.dp))

        Text(
            text = "词表选择",
            style = MaterialTheme.typography.titleMedium,
            color = TextSecondary
        )
        Text(
            text = "选择搜索时要匹配的词表",
            style = MaterialTheme.typography.bodyMedium,
            color = TextTertiary
        )

        Spacer(modifier = Modifier.height(12.dp))

        Card(
            shape = RoundedCornerShape(16.dp),
            colors = CardDefaults.cardColors(containerColor = DarkCard)
        ) {
            Column {
                WordbookSwitch(
                    title = "CET-4 四级",
                    subtitle = "大学英语四级核心词汇",
                    checked = selection[WordbookId.CET4] == true,
                    onToggle = { viewModel.toggle(WordbookId.CET4) }
                )
                WordbookSwitch(
                    title = "CET-6 六级",
                    subtitle = "大学英语六级核心词汇",
                    checked = selection[WordbookId.CET6] == true,
                    onToggle = { viewModel.toggle(WordbookId.CET6) }
                )
                WordbookSwitch(
                    title = "IELTS 雅思",
                    subtitle = "雅思考试高频词汇",
                    checked = selection[WordbookId.IELTS] == true,
                    onToggle = { viewModel.toggle(WordbookId.IELTS) }
                )
                WordbookSwitch(
                    title = "TOEFL 托福",
                    subtitle = "托福考试高频词汇",
                    checked = selection[WordbookId.TOEFL] == true,
                    onToggle = { viewModel.toggle(WordbookId.TOEFL) }
                )
            }
        }

        Spacer(modifier = Modifier.height(24.dp))

        Text(
            text = "关于",
            style = MaterialTheme.typography.titleMedium,
            color = TextSecondary
        )

        Spacer(modifier = Modifier.height(12.dp))

        Card(
            shape = RoundedCornerShape(16.dp),
            colors = CardDefaults.cardColors(containerColor = DarkCard)
        ) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .clickable { onOpenAbout() }
                    .padding(16.dp)
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        imageVector = Icons.Default.Info,
                        contentDescription = null,
                        tint = AccentGold,
                        modifier = Modifier.size(18.dp)
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        text = "关于 SingWord",
                        style = MaterialTheme.typography.titleMedium,
                        color = MaterialTheme.colorScheme.onSurface
                    )
                    Spacer(modifier = Modifier.weight(1f))
                    Icon(
                        imageVector = Icons.AutoMirrored.Filled.KeyboardArrowRight,
                        contentDescription = null,
                        tint = TextTertiary
                    )
                }

                Spacer(modifier = Modifier.height(6.dp))
                Text(
                    text = "查看词书参考源详细地址与项目仓库",
                    style = MaterialTheme.typography.bodyMedium,
                    color = TextSecondary
                )
            }
        }

        if (!uiState.warning.isNullOrBlank()) {
            Spacer(modifier = Modifier.height(16.dp))
            Text(
                text = uiState.warning!!,
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.error
            )
        }
    }
}

@Composable
private fun WordbookSwitch(
    title: String,
    subtitle: String,
    checked: Boolean,
    onToggle: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 12.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = title,
                style = MaterialTheme.typography.titleMedium,
                color = MaterialTheme.colorScheme.onSurface
            )
            Text(
                text = subtitle,
                style = MaterialTheme.typography.bodyMedium,
                color = TextTertiary
            )
        }
        Switch(
            checked = checked,
            onCheckedChange = { onToggle() },
            colors = SwitchDefaults.colors(
                checkedThumbColor = AccentGold,
                checkedTrackColor = AccentGold.copy(alpha = 0.3f),
                uncheckedThumbColor = TextTertiary,
                uncheckedTrackColor = DarkSurfaceVariant
            )
        )
    }
}
