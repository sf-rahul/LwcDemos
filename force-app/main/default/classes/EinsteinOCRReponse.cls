public class EinsteinOCRReponse {
    public list<Probability> probabilities{get;set;}
    public String objects{get;set;}
    public String task{get;set;}
    public class Probability{
        public boundingBox boundingBox{get;set;}
        public String label{get;set;}
        public Decimal probability{get;set;}
    }
    public class BoundingBox{
        public Integer maxX{get;set;}
        public Integer minY{get;set;}
        public Integer maxY{get;set;}
        public Integer minX{get;set;}
    }
    
    public static EinsteinOCRReponse parse(String json) {
		return (EinsteinOCRReponse) System.JSON.deserialize(json, EinsteinOCRReponse.class);
	}
}