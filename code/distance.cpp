#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]

List map_to_reference(std::string sequence, std::vector< std::string > references) {

	int n_refs = references.size();
	int seq_length = sequence.length();

	std::vector<int> matches;
	double min_dist = 1.0;

	for(int r=0;r<n_refs;r++){
		std::string ref = references[r];
		double difference = 0;
		double total = 0;

		for(int l=0;l<seq_length;l++){
			char base = sequence[l];

			if(!(base == '.' || ref[l] == '.'  || (base == '-' && ref[l] == '-'))){
				if(base != ref[l]){	difference++;	}
				total++;
			}
		}

		double distance = (double) difference / total;

		if(distance < min_dist){
			min_dist = distance;
			matches.resize(1);
			matches[0] = r+1;
		} else if (distance == min_dist){
			matches.push_back(r+1);
		}

	}

	return List::create(min_dist, matches);
}
