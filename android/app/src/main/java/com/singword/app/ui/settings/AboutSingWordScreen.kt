package com.singword.app.ui.settings

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.Link
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalUriHandler
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.unit.dp
import com.singword.app.ui.common.noRippleClickable

private data class SourceLink(
    val title: String,
    val url: String,
    val note: String
)

private data class SourceSection(
    val title: String,
    val description: String,
    val links: List<SourceLink>
)

private val sourceSections = listOf(
    SourceSection(
        title = "项目",
        description = "SingWord 仓库地址",
        links = listOf(
            SourceLink(
                title = "GitHub 仓库",
                url = "https://github.com/ink1ing/singword",
                note = "项目源码与文档"
            )
        )
    ),
    SourceSection(
        title = "CET-4 词书来源",
        description = "当前打包词书实际导入数据源",
        links = listOf(
            SourceLink(
                title = "ZE3kr/MemWords-CN cet4.csv",
                url = "https://raw.githubusercontent.com/ZE3kr/MemWords-CN/fa974dfe3ceb6cb65fec3b8ca87de3285d8891c1/cet4.csv",
                note = "MIT"
            )
        )
    ),
    SourceSection(
        title = "CET-6 词书来源",
        description = "当前打包词书实际导入数据源",
        links = listOf(
            SourceLink(
                title = "mahavivo/english-wordlists CET6_edited.txt",
                url = "https://raw.githubusercontent.com/mahavivo/english-wordlists/395cebd583d97be61b065d281d16dc49c7e4a8b0/CET6_edited.txt",
                note = "开源词表"
            )
        )
    ),
    SourceSection(
        title = "IELTS 词书来源",
        description = "当前打包词书实际导入数据源（含补充）",
        links = listOf(
            SourceLink(
                title = "hefengxian/ielts-vocabulary vocabulary.js",
                url = "https://raw.githubusercontent.com/hefengxian/ielts-vocabulary/d59669c8c55da843ce5996e3349e8cf0883c30db/vocabulary.js",
                note = "MIT"
            ),
            SourceLink(
                title = "learning-zone/ielts-materials vocabulary.md",
                url = "https://raw.githubusercontent.com/learning-zone/ielts-materials/61cb945f8d5a9be4b4b8be8c03e37d60940df2ae/vocabulary.md",
                note = "MIT 补充"
            )
        )
    ),
    SourceSection(
        title = "TOEFL 词书来源",
        description = "当前打包词书实际导入数据源（含 4300 与扩展）",
        links = listOf(
            SourceLink(
                title = "ZE3kr/MemWords-CN word.csv",
                url = "https://raw.githubusercontent.com/ZE3kr/MemWords-CN/fa974dfe3ceb6cb65fec3b8ca87de3285d8891c1/word.csv",
                note = "MIT"
            ),
            SourceLink(
                title = "ladrift/toefl wangyumei-toefl-words.txt",
                url = "https://raw.githubusercontent.com/ladrift/toefl/832ef58460242c32f8fbaa90face59c8dffc9ba1/words/wangyumei-toefl-words.txt",
                note = "MIT"
            ),
            SourceLink(
                title = "Lina-Liuna toefl power vocab",
                url = "https://raw.githubusercontent.com/Lina-Liuna/Lina-Liuna.github.io/3407b6d38174bc93f669b1f3d61bcd42cba20763/js/linked_TOEFL_Power_Vocab.js",
                note = "MIT 补充"
            ),
            SourceLink(
                title = "Lina-Liuna toefl quiz data",
                url = "https://raw.githubusercontent.com/Lina-Liuna/Lina-Liuna.github.io/3407b6d38174bc93f669b1f3d61bcd42cba20763/js/linked_quizdata.js",
                note = "MIT 补充"
            )
        )
    )
)

@Composable
fun AboutSingWordScreen(onBack: () -> Unit) {
    val uriHandler = LocalUriHandler.current

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
            .padding(horizontal = 16.dp)
    ) {
        Spacer(modifier = Modifier.height(12.dp))

        Row(verticalAlignment = Alignment.CenterVertically) {
            IconButton(onClick = onBack) {
                Icon(
                    imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                    contentDescription = "返回",
                    tint = MaterialTheme.colorScheme.onBackground
                )
            }
            Icon(
                Icons.Default.Info,
                contentDescription = null,
                tint = MaterialTheme.colorScheme.primary,
                modifier = Modifier.size(24.dp)
            )
            Spacer(modifier = Modifier.width(8.dp))
            Text(
                text = "关于 SingWord",
                style = MaterialTheme.typography.headlineMedium,
                color = MaterialTheme.colorScheme.onBackground
            )
        }

        Spacer(modifier = Modifier.height(12.dp))

        LazyColumn(verticalArrangement = Arrangement.spacedBy(10.dp)) {
            item {
                Text(
                    text = "以下为当前项目词书构建使用的参考源详细地址。",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }

            sourceSections.forEach { section ->
                item {
                    Card(
                        shape = RoundedCornerShape(16.dp),
                        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface)
                    ) {
                        Column(modifier = Modifier.padding(14.dp)) {
                            Text(
                                text = section.title,
                                style = MaterialTheme.typography.titleMedium,
                                color = MaterialTheme.colorScheme.onSurface
                            )
                            Spacer(modifier = Modifier.height(2.dp))
                            Text(
                                text = section.description,
                                style = MaterialTheme.typography.bodySmall,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )

                            section.links.forEach { link ->
                                Spacer(modifier = Modifier.height(10.dp))
                                Row(verticalAlignment = Alignment.Top) {
                                    Icon(
                                        Icons.Default.Link,
                                        contentDescription = null,
                                        tint = MaterialTheme.colorScheme.primary,
                                        modifier = Modifier
                                            .size(16.dp)
                                            .padding(top = 2.dp)
                                    )
                                    Spacer(modifier = Modifier.width(6.dp))
                                    Column {
                                        Text(
                                            text = link.title,
                                            style = MaterialTheme.typography.bodyMedium,
                                            color = MaterialTheme.colorScheme.onSurface
                                        )
                                        if (link.note.isNotBlank()) {
                                            Text(
                                                text = link.note,
                                                style = MaterialTheme.typography.bodySmall,
                                                color = MaterialTheme.colorScheme.onSurfaceVariant
                                            )
                                        }
                                        Text(
                                            text = link.url,
                                            style = MaterialTheme.typography.bodySmall,
                                            color = MaterialTheme.colorScheme.tertiary,
                                            textDecoration = TextDecoration.Underline,
                                            modifier = Modifier
                                                .fillMaxWidth()
                                                .noRippleClickable { uriHandler.openUri(link.url) }
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
            }

            item {
                Spacer(modifier = Modifier.height(12.dp))
            }
        }
    }
}
