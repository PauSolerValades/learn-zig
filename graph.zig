const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var graph = Graph(u8, f16, 4).init(allocator);

    try graph.newNode(13);
    try graph.newNode(10);
    try graph.newNode(11);
    try graph.newNode(3);


    try graph.newEdge(3, 10, null);
    try graph.newEdge(10, 3, 2);

}


pub fn Graph(comptime T: type, comptime W: type, comptime capacity: u32) type {

    return struct {
        // Asi es como se deberia hacer.
        // Pero vamos a llamar nosotros directamente
        // a @This()
        // Mentira.
        const Self = @This();
        allocator: Allocator,
        node_count: usize,
        edge_count: usize,
        nodes: [capacity]*Node,
        edges: [capacity]*Edge,

        const Node = struct {
            id: usize,
            value: T,
        };

        const Edge = struct {
            from: *Node,
            to: *Node,
            weight: ?W,
        };


        const GraphErrors = error {
            NodeNotFound,
        };

        pub fn init(allocator: Allocator) Self {
            return Self {
                .allocator = allocator,
                .nodes = undefined,
                .edges = undefined,
                .node_count = 0,
                .edge_count = 0,
            };
        }

        pub fn newNode(self: *Self, value: T) error{IndexOutOfBounds, OutOfMemory}!void { // No se queja :)
            
            if (self.nodes.len <= self.node_count) return error.IndexOutOfBounds;
            
            // create és la funció que voliem, no alloc
            const node_ptr = try self.allocator.create(Node);
            
            node_ptr.* = .{
                .id = self.node_count,
                .value = value,
            };

            self.nodes[self.node_count] = node_ptr;

            self.node_count += 1;
        }

        fn getNodeByValue(self: Self, value: T) !usize{
            for (0.., self.nodes) |i, node| {
                std.debug.print("Node {}: {}\n", .{i, node.value});
                if (node.value == value) {
                    return i;
                }
            }

            return GraphErrors.NodeNotFound;
        }

        pub fn newEdge(self: *Self, value_from: T, value_to: T, weight: ?W) !void {

            if (self.edges.len <= self.edge_count) return error.IndexOutOfBounds; 
            const node_from = try self.getNodeByValue(value_from);
            const node_to = try self.getNodeByValue(value_to);

            const edge_ptr = try self.allocator.create(Edge);
            
            edge_ptr.from = self.nodes[node_from];
            edge_ptr.to = self.nodes[node_to];

            edge_ptr.weight = null;

            if (weight) |w| {
                edge_ptr.weight = w;
            }

            self.edges[self.edge_count] = edge_ptr;

            self.edge_count += 1;

            //return error.IndexOutOfBounds; 
        }

    };
}


