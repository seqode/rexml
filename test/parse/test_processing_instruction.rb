require "test/unit"
require "rexml/document"

module REXMLTests
  class TestParseProcessinInstruction < Test::Unit::TestCase
    def parse(xml)
      REXML::Document.new(xml)
    end

    class TestInvalid < self
      def test_no_name
        exception = assert_raise(REXML::ParseException) do
          parse("<??>")
        end
        assert_equal(<<-DETAIL.chomp, exception.to_s)
Invalid processing instruction node
Line: 1
Position: 4
Last 80 unconsumed characters:
<??>
        DETAIL
      end

      def test_garbage_text
        # TODO: This should be parse error.
        # Create test/parse/test_document.rb or something and move this to it.
        doc = parse(<<-XML)
x<?x y
<!--?><?x -->?>
<r/>
        XML
        pi = doc.children[1]
        assert_equal([
                       "x",
                       "y\n<!--",
                     ],
                     [
                       pi.target,
                       pi.content,
                     ])
      end
    end

    def test_after_root
      parser = REXML::Parsers::BaseParser.new('<a></a><?abc version="1.0" ?>')

      events = {}
      while parser.has_next?
        event = parser.pull
        events[event[0]] = event[1]
      end

      assert_equal("abc", events[:processing_instruction])
    end
  end
end
