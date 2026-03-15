import SwiftUI
import WidgetKit

@main
struct InspireMeWidgetBundle: WidgetBundle {
    var body: some Widget {
        QuoteOfTheDayWidget()
        RandomQuoteWidget()
    }
}
