import SwiftUI

private struct SourceLink: Hashable {
    let title: String
    let url: String
    let note: String
}

private struct SourceSection: Hashable {
    let title: String
    let description: String
    let links: [SourceLink]
}

private let sourceSections: [SourceSection] = [
    SourceSection(
        title: "项目",
        description: "SingWord 仓库地址",
        links: [
            SourceLink(
                title: "GitHub 仓库",
                url: "https://github.com/ink1ing/singword",
                note: "项目源码与文档"
            )
        ]
    ),
    SourceSection(
        title: "CET-4 词书来源",
        description: "当前打包词书实际导入数据源",
        links: [
            SourceLink(
                title: "ZE3kr/MemWords-CN cet4.csv",
                url: "https://raw.githubusercontent.com/ZE3kr/MemWords-CN/fa974dfe3ceb6cb65fec3b8ca87de3285d8891c1/cet4.csv",
                note: "MIT"
            )
        ]
    ),
    SourceSection(
        title: "CET-6 词书来源",
        description: "当前打包词书实际导入数据源",
        links: [
            SourceLink(
                title: "mahavivo/english-wordlists CET6_edited.txt",
                url: "https://raw.githubusercontent.com/mahavivo/english-wordlists/395cebd583d97be61b065d281d16dc49c7e4a8b0/CET6_edited.txt",
                note: "开源词表"
            )
        ]
    ),
    SourceSection(
        title: "IELTS 词书来源",
        description: "当前打包词书实际导入数据源（含补充）",
        links: [
            SourceLink(
                title: "hefengxian/ielts-vocabulary vocabulary.js",
                url: "https://raw.githubusercontent.com/hefengxian/ielts-vocabulary/d59669c8c55da843ce5996e3349e8cf0883c30db/vocabulary.js",
                note: "MIT"
            ),
            SourceLink(
                title: "learning-zone/ielts-materials vocabulary.md",
                url: "https://raw.githubusercontent.com/learning-zone/ielts-materials/61cb945f8d5a9be4b4b8be8c03e37d60940df2ae/vocabulary.md",
                note: "MIT 补充"
            )
        ]
    ),
    SourceSection(
        title: "TOEFL 词书来源",
        description: "当前打包词书实际导入数据源（含 4300 与扩展）",
        links: [
            SourceLink(
                title: "ZE3kr/MemWords-CN word.csv",
                url: "https://raw.githubusercontent.com/ZE3kr/MemWords-CN/fa974dfe3ceb6cb65fec3b8ca87de3285d8891c1/word.csv",
                note: "MIT"
            ),
            SourceLink(
                title: "ladrift/toefl wangyumei-toefl-words.txt",
                url: "https://raw.githubusercontent.com/ladrift/toefl/832ef58460242c32f8fbaa90face59c8dffc9ba1/words/wangyumei-toefl-words.txt",
                note: "MIT"
            ),
            SourceLink(
                title: "Lina-Liuna toefl power vocab",
                url: "https://raw.githubusercontent.com/Lina-Liuna/Lina-Liuna.github.io/3407b6d38174bc93f669b1f3d61bcd42cba20763/js/linked_TOEFL_Power_Vocab.js",
                note: "MIT 补充"
            ),
            SourceLink(
                title: "Lina-Liuna toefl quiz data",
                url: "https://raw.githubusercontent.com/Lina-Liuna/Lina-Liuna.github.io/3407b6d38174bc93f669b1f3d61bcd42cba20763/js/linked_quizdata.js",
                note: "MIT 补充"
            )
        ]
    )
]

struct AboutSingWordScreen: View {
    var body: some View {
        List {
            Text("以下为当前项目词书构建使用的参考源详细地址。")
                .font(SingWordTypography.bodyMedium)
                .foregroundStyle(.secondary)

            ForEach(sourceSections, id: \.self) { section in
                Section(section.title) {
                    Text(section.description)
                        .font(SingWordTypography.labelMedium)
                        .foregroundStyle(.secondary)
                    ForEach(section.links, id: \.self) { link in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(link.title)
                                .font(SingWordTypography.bodyMedium)
                            if !link.note.isEmpty {
                                Text(link.note)
                                    .font(SingWordTypography.labelMedium)
                                    .foregroundStyle(.secondary)
                            }
                            if let url = URL(string: link.url) {
                                Link(link.url, destination: url)
                                    .font(SingWordTypography.labelMedium)
                            } else {
                                Text(link.url)
                                    .font(SingWordTypography.labelMedium)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle("关于 SingWord")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }
}
