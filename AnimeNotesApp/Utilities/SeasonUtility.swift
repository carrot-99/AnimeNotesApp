// SeasonUtility.swift

struct SeasonUtility {
    static func parseSeasonComponents(from season: String) -> (year: Int, season: String) {
        let yearString = String(season.prefix(4))
        let seasonString = String(season.dropFirst(4))
        if let year = Int(yearString) {
            let firestoreSeasonFormat = mapSeasonToFirestoreFormat(seasonString)
            return (year, firestoreSeasonFormat)
        } else {
            return (0, "")
        }
    }
    
    private static func mapSeasonToFirestoreFormat(_ season: String) -> String {
        switch season {
        case "春":
            return "SPRING"
        case "夏":
            return "SUMMER"
        case "秋":
            return "FALL"
        case "冬":
            return "WINTER"
        default:
            return season // またはエラーハンドリング
        }
    }
}
