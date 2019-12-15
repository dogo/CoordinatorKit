public protocol Responder {
    var nextResponder: AnyCoordinator? { get set }
}

public extension AnyCoordinator {
    func tryToHandle<EventType: Event>(_ message: EventType) {
        message.tryToSendTo(self)
    }
}

public extension Event {
    func tryToSendTo(_ firstResponder: Responder) {
        guard let handler: Handler = findHandlerInChainStartingWith(firstResponder) else {
            fatalError("declared event \(self) was not found in the chained structure")
        }
        sendToHandler(handler)
    }

    private func findHandlerInChainStartingWith<Handler>(_ firstResponder: Responder) -> Handler? {
        var nextResponder: Responder? = firstResponder
        while let responder = nextResponder {
            if let handler = responder as? Handler {
                return handler
            }
            #if DEBUG
                print("\(responder) cannot handle the message")
            #endif
            nextResponder = responder.nextResponder
        }
        return nil
    }
}
