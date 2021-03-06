require 'chronic_duration'

describe ChronicDuration, '.parse' do

  @exemplars = {
    '1:20'                  => 60 + 20,
    '1:20.51'               => 60 + 20.51,
    '4:01:01'               => 4 * 3600 + 60 + 1,
    '3 mins 4 sec'          => 3 * 60 + 4,
    '3 Mins 4 Sec'          => 3 * 60 + 4,
    'three mins four sec'          => 3 * 60 + 4,
    '2 hrs 20 min'          => 2 * 3600 + 20 * 60,
    '2h20min'               => 2 * 3600 + 20 * 60,
    '6 mos 1 day'           => 6 * 30 * 24 * 3600 + 24 * 3600,
    '1 year 6 mos 1 day'    => 1 * 31536000 + 6 * 30 * 24 * 3600 + 24 * 3600,
    '2.5 hrs'               => 2.5 * 3600,
    '47 yrs 6 mos and 4.5d' => 47 * 31536000 + 6 * 30 * 24 * 3600 + 4.5 * 24 * 3600,
    'two hours and twenty minutes' => 2 * 3600 + 20 * 60,
    'four hours and forty minutes' => 4 * 3600 + 40 * 60,
    'four hours, and fourty minutes' => 4 * 3600 + 40 * 60,
    '3 weeks and, 2 days' => 3600 * 24 * 7 * 3 + 3600 * 24 * 2,
    '3 weeks, plus 2 days' => 3600 * 24 * 7 * 3 + 3600 * 24 * 2,
    '3 weeks with 2 days' => 3600 * 24 * 7 * 3 + 3600 * 24 * 2,
    '1 month'               => 3600 * 24 * 30,
    '2 months'              => 3600 * 24 * 30 * 2,
    'day'                   => 3600 * 24,
    'minute 30s'            => 90
  }

  it "should return nil if the string can't be parsed" do
    ChronicDuration.parse('gobblygoo').should be_nil
  end

  it "should return nil if the string parses as zero" do
    ChronicDuration.parse('0').should be_nil
  end

  it "should return zero if the string parses as zero and the keep_zero option is true" do
    ChronicDuration.parse('0', :keep_zero => true).should == 0
  end

  it "should raise an exception if the string can't be parsed and @@raise_exceptions is set to true" do
    ChronicDuration.raise_exceptions = true
    lambda { ChronicDuration.parse('23 gobblygoos') }.should raise_exception(ChronicDuration::DurationParseError)
    ChronicDuration.raise_exceptions = false
  end

  it "should return a float if seconds are in decimals" do
    ChronicDuration.parse('12 mins 3.141 seconds').is_a?(Float).should be_true
  end

  it "should return an integer unless the seconds are in decimals" do
    ChronicDuration.parse('12 mins 3 seconds').is_a?(Integer).should be_true
  end

  it "should be able to parse minutes by default" do
    ChronicDuration.parse('5', :default_unit => "minutes").should == 300
  end

  @exemplars.each do |k, v|
    it "should properly parse a duration like #{k}" do
      ChronicDuration.parse(k).should == v
    end
  end

end

describe ChronicDuration, '.output' do

  it "should return nil if the input can't be parsed" do
    ChronicDuration.parse('gobblygoo').should be_nil
  end

  @exemplars = {
    #(0) =>
      #{
        #:micro    => '0s',
        #:short    => '0s',
        #:default  => '0 secs',
        #:long     => '0 seconds',
        #:chrono   => '0'
      #},
    (60 + 20) =>
      {
        :micro    => '1m20s',
        :short    => '1m 20s',
        :default  => '1 min 20 secs',
        :long     => '1 minute 20 seconds',
        :chrono   => '1:20'
      },
    (60 + 20 + 0.0) =>
      {
        :micro    => '1m20s',
        :short    => '1m 20s',
        :default  => '1 min 20 secs',
        :long     => '1 minute 20 seconds',
        :chrono   => '1:20'
      },
    (60 + 20.01) =>
      {
        :micro    => '1m20.01s',
        :short    => '1m 20.01s',
        :default  => '1 min 20.01 secs',
        :long     => '1 minute 20.01 seconds',
        :chrono   => '1:20.01'
      },
    (60 + 20.1) =>
      {
        :micro    => '1m20.1s',
        :short    => '1m 20.1s',
        :default  => '1 min 20.1 secs',
        :long     => '1 minute 20.1 seconds',
        :chrono   => '1:20.1'
      },
    (60 + 0.1) =>
      {
        :micro    => '1m0.1s',
        :short    => '1m 0.1s',
        :default  => '1 min 0.1 secs',
        :long     => '1 minute 0.1 seconds',
        :chrono   => '1:00.1'
      },
    (60*60) =>
      {
        :micro    => '1h',
        :short    => '1h',
        :default  => '1 hr',
        :long     => '1 hour',
        :chrono   => '1:00:00'
      },
    (60*60 + 0.1) =>
      {
        :micro    => '1h0.1s',
        :short    => '1h 0.1s',
        :default  => '1 hr 0.1 secs',
        :long     => '1 hour 0.1 seconds',
        :chrono   => '1:00:00.1'
      },
    (60 + 20.51) =>
      {
        :micro    => '1m20.51s',
        :short    => '1m 20.51s',
        :default  => '1 min 20.51 secs',
        :long     => '1 minute 20.51 seconds',
        :chrono   => '1:20.51'
      },
    (60 + 20.51928) =>
      {
        :micro    => '1m20.51928s',
        :short    => '1m 20.51928s',
        :default  => '1 min 20.51928 secs',
        :long     => '1 minute 20.51928 seconds',
        :chrono   => '1:20.51928'
      },
    (4 * 3600 + 60 + 1) =>
      {
        :micro    => '4h1m1s',
        :short    => '4h 1m 1s',
        :default  => '4 hrs 1 min 1 sec',
        :long     => '4 hours 1 minute 1 second',
        :chrono   => '4:01:01'
      },
    (2 * 3600 + 20 * 60) =>
      {
        :micro    => '2h20m',
        :short    => '2h 20m',
        :default  => '2 hrs 20 mins',
        :long     => '2 hours 20 minutes',
        :chrono   => '2:20'
      },
    (2 * 3600 + 20 * 60) =>
      {
        :micro    => '2h20m',
        :short    => '2h 20m',
        :default  => '2 hrs 20 mins',
        :long     => '2 hours 20 minutes',
        :chrono   => '2:20:00'
      },
    (6 * 30 * 24 * 3600 + 24 * 3600) =>
      {
        :micro    => '6mo1d',
        :short    => '6mo 1d',
        :default  => '6 mos 1 day',
        :long     => '6 months 1 day',
        :chrono   => '6:01:00:00:00' # Yuck. FIXME
      },
    (365 * 24 * 3600 + 24 * 3600 ) =>
      {
        :micro    => '1y1d',
        :short    => '1y 1d',
        :default  => '1 yr 1 day',
        :long     => '1 year 1 day',
        :chrono   => '1:00:01:00:00:00'
      },
    (3  * 365 * 24 * 3600 + 24 * 3600 ) =>
      {
        :micro    => '3y1d',
        :short    => '3y 1d',
        :default  => '3 yrs 1 day',
        :long     => '3 years 1 day',
        :chrono   => '3:00:01:00:00:00'
      },
  }

  @exemplars.each do |k, v|
    v.each do |key, val|
      it "should properly output a duration of #{k} seconds as #{val} using the #{key.to_s} format option" do
        ChronicDuration.output(k, :format => key).should == val
      end
    end
  end

  @keep_zero_exemplars = {
    (true) =>
      {
        :micro    => '0s',
        :short    => '0s',
        :default  => '0 secs',
        :long     => '0 seconds',
        :chrono   => '0'
      },
    (false) =>
      {
        :micro    => nil,
        :short    => nil,
        :default  => nil,
        :long     => nil,
        :chrono   => '0'
      },
  }

  @keep_zero_exemplars.each do |k, v|
    v.each do |key, val|
      it "should properly output a duration of 0 seconds as #{val.nil? ? "nil" : val} using the #{key.to_s} format option, if the keep_zero option is #{k.to_s}" do
        ChronicDuration.output(0, :format => key, :keep_zero => k).should == val
      end
    end
  end

  it "should show weeks when needed" do
    ChronicDuration.output(15*24*60*60, :weeks => true).should =~ /.*wk.*/
  end

  it "should show the specified number of units if provided" do
    ChronicDuration.output(4 * 3600 + 60 + 1, units: 2).should == '4 hrs 1 min'
    ChronicDuration.output(6 * 30 * 24 * 3600 + 24 * 3600 + 3600 + 60 + 1, units: 3, format: :long).should == '6 months 1 day 1 hour'
  end

  it "should use the default format when the format is not specified" do
    ChronicDuration.output(2 * 3600 + 20 * 60).should == '2 hrs 20 mins'
  end

  @exemplars.each do |seconds,format_spec|
    format_spec.each do |format,_|
      it "it should properly output a duration for #{seconds} that parses back to the same thing when using the #{format.to_s} format" do
        ChronicDuration.parse(ChronicDuration.output(seconds, :format => format)).should == seconds
      end
    end
  end
end


# Some of the private methods deserve some spec'ing to aid
# us in development...

describe ChronicDuration, "private methods" do

  describe ".filter_by_type" do

    it "should take a chrono-formatted time like 3:14 and return a human time like 3 minutes 14 seconds" do
      ChronicDuration.instance_eval("filter_by_type('3:14')").should == '3 minutes 14 seconds'
    end

    it "should take a chrono-formatted time like 12:10:14 and return a human time like 12 hours 10 minutes 14 seconds" do
      ChronicDuration.instance_eval("filter_by_type('12:10:14')").should == '12 hours 10 minutes 14 seconds'
    end

    it "should return the input if it's not a chrono-formatted time" do
      ChronicDuration.instance_eval("filter_by_type('4 hours')").should == '4 hours'
    end

  end

  describe ".cleanup" do

    it "should clean up extraneous words" do
      ChronicDuration.instance_eval("cleanup('4 days and 11 hours')").should == '4 days 11 hours'
    end

    it "should cleanup extraneous spaces" do
      ChronicDuration.instance_eval("cleanup('  4 days and 11     hours')").should == '4 days 11 hours'
    end

    it "should insert spaces where there aren't any" do
      ChronicDuration.instance_eval("cleanup('4m11.5s')").should == '4 minutes 11.5 seconds'
    end

  end

end
