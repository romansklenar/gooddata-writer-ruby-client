require 'test_helper'

class Keboola::GoodDataWriterTest < Minitest::Test
  def test_it_has_a_version_number
    refute_nil ::Keboola::GoodDataWriter::VERSION
  end
end
