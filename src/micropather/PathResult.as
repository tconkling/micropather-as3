//
// micropather

package micropather {

public class PathResult
{
    public static const NO_SOLUTION :PathResult = new PathResult();
    public static const START_END_SAME :PathResult = new PathResult();

    /** The Array of nodes that make up the path, if the pathfinding was successful */
    public function get path () :Array { return _path; }

    /** True if this PathResult contains a successful path */
    public function get isSolution () :Boolean { return _path != null; }

    /** The first node in the path */
    public function get start () :* { return _path[0]; }
    /** The last node in the path */
    public function get end () :* { return _path[_path.length - 1]; }

    internal static function solved (path :Array) :PathResult {
        var out :PathResult = new PathResult();
        out._path = path;
        return out;
    }

    private var _path :Array;
}
}
