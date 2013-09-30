//
// micropather

package micropather {

public class PathResult
{
    public static const SOLVED :int = 0;
    public static const NO_SOLUTION :int = 1;
    public static const START_END_SAME :int = 2;

    /** An int representing the type of result this is */
    public function get resultType () :int { return _resultType; }
    /** The Vector of nodes that make up the path, if the pathfinding was successful */
    public function get path () :Vector.<Object> { return _path; }

    /** True if this PathResult contains a successful path */
    public function get isSolution () :Boolean { return _resultType == SOLVED; }

    /** The first node in the path */
    public function get start () :* { return _path[0]; }
    /** The last node in the path */
    public function get end () :* { return _path[_path.length - 1]; }

    internal static function solved (path :Vector.<Object>) :PathResult {
        var out :PathResult = new PathResult();
        out._resultType = SOLVED;
        out._path = path;
        return out;
    }

    internal static function noSolution () :PathResult {
        var out :PathResult = new PathResult();
        out._resultType = NO_SOLUTION;
        return out;
    }

    internal static function startEndSame () :PathResult {
        var out :PathResult = new PathResult();
        out._resultType = START_END_SAME;
        return out;
    }

    private var _resultType :int;
    private var _path :Vector.<Object>;
}
}
