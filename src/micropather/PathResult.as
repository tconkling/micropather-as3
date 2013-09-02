//
// micropather

package micropather {

public class PathResult
{
    public static const SOLVED :int = 0;
    public static const NO_SOLUTION :int = 1;
    public static const START_END_SAME :int = 2;

    public function get result () :int { return _result; }
    public function get path () :Vector.<int> { return _path; }

    internal static function solved (path :Vector.<int>) :PathResult {
        var out :PathResult = new PathResult();
        out._result = SOLVED;
        out._path = path;
        return out;
    }

    internal static function noSolution () :PathResult {
        var out :PathResult = new PathResult();
        out._result = NO_SOLUTION;
        return out;
    }

    internal static function startEndSame () :PathResult {
        var out :PathResult = new PathResult();
        out._result = START_END_SAME;
        return out;
    }

    private var _result :int;
    private var _path :Vector.<int>;
}
}
