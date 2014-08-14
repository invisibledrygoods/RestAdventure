class Journal
  attr_reader :db

  Fixnum = proc &:to_i
  String = proc &:to_s
  Float = proc &:to_f

  def initialize(filename, schema={})
    File.open(filename, 'a') { }
    @db = filename
    @struct = Struct.new *schema.keys
    @defrost = schema.values
  end

  def all
    rows = []
    each do |row|
      rows << row
    end
    rows
  end

  def each
    File.open(@db, 'r') do |file|
      file.each do |line|
        next if line.start_with? '#'
        yield deserialize line
      end
    end
  end

  def where(&blk)
    rows = []
    File.open(@db, 'r') do |file|
      file.each do |line|
        next if line.start_with? '#'
        deserialized = deserialize line
        rows << deserialized if deserialized.instance_eval &blk
      end
    end
    rows
  end

  def delete_where(&blk)
    File.open(@db, 'r+') do |file|
      file.each do |line|
        next if line.start_with? '#'
        if deserialize(line).instance_eval &blk
          file.seek(-line.length - 1, IO::SEEK_CUR)
          file.print '#' * (line.length - 1)
        end
      end
    end
  end

  def update(values={})
   Updater.new self, values
  end

  def append(row={})
    File.open(@db, 'a') do |file|
      file.puts serialize row
    end
    row
  end

  def sanitize(unsafe)
    unsafe.gsub! '&', '&amp;'
    unsafe.gsub! '#', '&hash;'
    unsafe.gsub! ',', '&comma;'
    unsafe.gsub! "\r", '&cr;'
    unsafe.gsub! "\n", '&lf;'
    unsafe
  end

  def unsanitize(safe)
    safe.gsub! '&comma;', ','
    safe.gsub! '&hash;', '#'
    safe.gsub! '&cr;', "\r"
    safe.gsub! '&lf;', "\n"
    safe.gsub! '&amp;', '&'
    safe
  end

  def serialize(row={})
    row = row.to_h
    
    @struct.members.map { |key| sanitize(row[key].to_s) }.join ','
  end

  def deserialize(line)
    values = line.chomp.split(',').zip(@defrost).map { |value, defrost| unsanitize(defrost.call(value)) }
    @struct.new *values
  end

  # this should be done automatically when a certain ratio of deleted entries is counted
  def scrub
  end

  class Updater
    def initialize(journal, with_values={})
      @journal = journal
      @with_values = with_values
    end

    def where(&blk)
      appends = []

      File.open(@journal.db, 'r+') do |file|
        file.each do |line|
          next if line.start_with? '#'
          row = @journal.deserialize(line)
          if row.instance_eval &blk
            file.seek(-line.length - 1, IO::SEEK_CUR)
            file.print '#' * (line.length - 1)
            appends << (row.to_h.merge @with_values)
          end
        end
      end

      appends.each do |append| 
        @journal.append append
      end
    end
  end
end
