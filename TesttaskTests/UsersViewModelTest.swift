//
//  UsersViewModelTest.swift
//  TesttaskTests
//
//  Created by Miguel T on 24/09/24.
//

import XCTest
@testable import Testtask

// Naming Strunturing: test_UnitOfWork_StateUnderTest_ExpectedBehaviour
// Example: test_SomeViewModel_someVar_shouldBeTrue
// Testing structure: Given, when, then

final class UsersViewModelTest: XCTestCase {

    override func setUpWithError() throws { }

    override func tearDownWithError() throws { }

    func test_UserViewModel_InitialValues_areCorrect() {
        let expectation = XCTestExpectation(description: "Initial values")
        
        Task { @MainActor in
            let vm = UsersViewModel()
            XCTAssert(vm.data == [])
            XCTAssert(vm.page == 0)
            XCTAssert(vm.pageSize > 0)
            XCTAssert(vm.data == [])
            expectation.fulfill()
        }
    }

    func test_services_areWorking() {
        let expectation = XCTestExpectation(description: "Check if network call works")
        Task { @MainActor in
            let vm = UsersViewModel()
            do {
                try await vm.getUsers()
                expectation.fulfill()
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
        wait(for: [expectation], timeout: 3.0)
    }

}
