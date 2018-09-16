//
//  Stack+Extension.swift
//  CoordinatorKit-iOS
//
//  Created by Bruno Fernandes on 9/15/18.
//  Copyright © 2018 bfernandesbfs. All rights reserved.
//

private var childKey: UInt8 = 1
private var parentKey: UInt8 = 2

extension CoordinatorStack {

    var childCoordinators: [Coordinator] {
        get { return AssociatedObject.get(base: self, key: &childKey) { return [] } }
        set { AssociatedObject.set(base: self, key: &childKey, value: newValue) }
    }

    var parent: Coordinator? {
        get { return AssociatedObject.get(base: self, key: &parentKey) }
        set { AssociatedObject.set(base: self, key: &parentKey, value: newValue) }
    }
}

extension CoordinatorStack where Self: Coordinator {

    public func modal(_ coordinator: Coordinator, animated: Bool) {
        add(coordinator: coordinator)
        coordinator.start()

        router?.isModal = true
        router?.present(coordinator, animated: animated)
    }

    public func show(_ coordinator: Coordinator, animated: Bool, completion: (()-> Void)?) {
        add(coordinator: coordinator)
        coordinator.start()

        router?.isModal = false
        router?.push(coordinator, animated: animated, completion: completion)

        if let completion = completion {
            completion()
        }
    }

    public func finish(animated: Bool, completion: (()-> Void)?) {
        guard let parent = parent else {
            fatalError("This is an root coordinator and can't be removed")
        }

        remove(coordinator: parent)

        if let router = parent.router, router.isModal {
            parent.router?.isModal = false
            parent.router?.dismissModule(animated: animated, completion: completion)
        }
        else {
            parent.router?.isModal = true
            parent.router?.popModule(animated: animated)

            if let completion = completion {
                completion()
            }
        }
    }

    // MARK: Private Methods

    private func add(coordinator: Coordinator) {
        print("Add child \(coordinator) in \(self)")

        var coordinator = coordinator
        for element in childCoordinators where element === coordinator {
            return
        }
        childCoordinators.append(coordinator)
        coordinator.parent = self
        coordinator.nextResponder = self
        if coordinator.router == nil {
            coordinator.router = router
        }
    }

    private func remove(coordinator: Coordinator) {
        print("Remove child \(self) in \(coordinator)")

        if !coordinator.childCoordinators.isEmpty {
            for (index, element) in coordinator.childCoordinators.enumerated() where element === self {
                coordinator.childCoordinators.remove(at: index)
                parent = nil
                break
            }
        }
    }
}