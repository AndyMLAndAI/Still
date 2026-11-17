import Foundation
import CoreGraphics
import UIKit

public final class ThumbnailCache: @unchecked Sendable {
    public static let shared = ThumbnailCache()

    private let maxCost: Int = 60 * 1024 * 1024 // 60 MB cap
    private let lock = NSLock()

    private final class CacheNode {
        let key: String
        let image: CGImage
        let cost: Int
        var prev: CacheNode?
        var next: CacheNode?

        init(key: String, image: CGImage, cost: Int) {
            self.key = key
            self.image = image
            self.cost = cost
        }
    }

    private var nodeMap: [String: CacheNode] = [:]
    private var head: CacheNode?
    private var tail: CacheNode?
    public private(set) var currentCost: Int = 0

    public init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func handleMemoryWarning() {
        removeAll()
    }

    public func get(forKey key: String) -> CGImage? {
        lock.lock()
        defer { lock.unlock() }

        guard let node = nodeMap[key] else { return nil }
        moveToHead(node)
        return node.image
    }

    public func set(_ image: CGImage, forKey key: String) {
        lock.lock()
        defer { lock.unlock() }

        let cost = image.bytesPerRow * image.height
        if let existing = nodeMap[key] {
            currentCost -= existing.cost
            removeNode(existing)
        }

        let newNode = CacheNode(key: key, image: image, cost: cost)
        nodeMap[key] = newNode
        addToHead(newNode)
        currentCost += cost

        // Evict LRU entries if exceeding maxCost
        while currentCost > maxCost, let oldest = tail {
            nodeMap.removeValue(forKey: oldest.key)
            currentCost = max(0, currentCost - oldest.cost)
            removeNode(oldest)
            if nodeMap.isEmpty {
                currentCost = 0
                break
            }
        }
    }

    public func removeAll() {
        lock.lock()
        defer { lock.unlock() }
        nodeMap.removeAll()
        head = nil
        tail = nil
        currentCost = 0
    }

    private func addToHead(_ node: CacheNode) {
        node.next = head
        node.prev = nil
        if let h = head {
            h.prev = node
        }
        head = node
        if tail == nil {
            tail = node
        }
    }

    private func removeNode(_ node: CacheNode) {
        if let p = node.prev {
            p.next = node.next
        } else {
            head = node.next
        }
        if let n = node.next {
            n.prev = node.prev
        } else {
            tail = node.prev
        }
        node.prev = nil
        node.next = nil
    }

    private func moveToHead(_ node: CacheNode) {
        guard head !== node else { return }
        removeNode(node)
        addToHead(node)
    }
}
