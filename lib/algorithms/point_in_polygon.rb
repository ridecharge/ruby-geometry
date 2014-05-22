module Geometry
  class PointInPolygon < Struct.new(:point, :polygon)
    extend Memoist
    
    def inside?
      point_location == :inside
    end

    def outside?
      point_location == :outside
    end

    def on_the_boundary?
      point_location == :on_the_boundary
    end

    def point_location
      return :outside unless bounding_box.contains?(point)
      return :on_the_boundary if point_is_vertex? || point_on_edge?

      intersection_count(Segment(point, Point(point.x + sufficient_ray_radius, point.y))).odd? ? :inside : :outside
    end

    delegate :vertices, :edges, :bounding_box, :to => :polygon
    memoize :point_location, :edges, :bounding_box

    private

    def point_is_vertex?
      vertices.any? { |vertex| vertex == point }
    end

    def point_on_edge?
      edges.any? { |edge| edge.contains_point?(point) }
    end
    
    def intersection_count(ray)
      edges.select { |edge| edge.intersects_with?(ray) }.size
    end

    def sufficient_ray_radius
      @sufficient_ray_radius ||= bounding_box.diagonal.length * 2
    end
  end
end
