//
//  ActionDispatcherTests.swift
//  multitools
//
//  Created by Mac on 25/10/2026.
//

import XCTest
@testable import multitools

private final class MockScreenService: ScreenCapturing {
    private(set) var wasCaptureCalled = false

    func capture() -> String {
        wasCaptureCalled = true
        return "Mock screenshot"
    }
}

final class ActionDispatcherTests: XCTestCase {
    func testCaptureScreenCallsScreenService() {
        let screen = MockScreenService()
        let dispatcher = ActionDispatcher(screen: screen)

        _ = dispatcher.execute(.screenCapture)

        XCTAssertTrue(screen.wasCaptureCalled)
    }
}
