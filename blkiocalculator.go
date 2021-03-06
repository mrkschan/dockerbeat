package main

type BlkioStats struct {
	reads  uint64
	writes uint64
	totals uint64
}

type BlkioCalculator struct {
	old BlkioStats
	new BlkioStats
}

func (c *BlkioCalculator) getRead() uint64 {
	return c.new.reads - c.old.reads
}

func (c *BlkioCalculator) getWrite() uint64 {
	return c.new.writes - c.old.writes
}

func (c *BlkioCalculator) getTotal() uint64 {
	return c.new.totals - c.old.totals
}
