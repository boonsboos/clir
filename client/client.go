package client

var clir_client Client

type Client struct {
	Busy        bool
	Scores      map[string]Score
	RecentChart Chart
	RecentScore Clir
	ScoreMtime  int64
	FoundChart  bool
}

type Clir struct {
	ScoreData Score
	ChartData Chart
}

func Run() {
	map_to_client()
	SongInfoForHash("a")
	for true {

	}
}

func compare_map() {

}

func map_scores() map[string]Score {
	tmp := map[string]Score{}
	a := DecodeScores()
	for i := range a {
		tmp[a[i].Hash] = a[i]
	}
	return tmp
}

func map_to_client() {
	clir_client.Scores = map_scores()
}
