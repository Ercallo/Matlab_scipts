function ci = bootstrapCIBca(X, x0, confidenceLevel)
% Opt fields:
%   .ConfidenceLevel

% Extract number of row/bootstrap samples (m) and number of columns/parameters
% in x0 (n).
m = size(X,1);
n = numel(x0);

if nargin < 3 || isempty(confidenceLevel)
    confidenceLevel = 0.95;
end

% Calculate bias-correction factor z0.
z0 = norminv(sum(bsxfun(@lt,X,x0), 1) / m);

% Means of Jackknife resampled X (mBoot "leave-one-out" resamples of X). Instead
% of doing the full resampling (see, e.g., DOI: 10.3389/fpsyg.2019.02215), we
% can simply convert the mean X into the mean of leave-one-out-X arrays. As we
% don't need the full Jackknife resample afterwards, this is more than three
% orders of magnitude faster and allows for bootstrap numbers > 1e5.
J = bsxfun(@minus, mean(X,1), X/m) * m/(m-1);
j0 = mean(J, 1);

% Calculate acceleration factor a.
a = sum(bsxfun(@minus, J, j0).^3, 1) ./ ...
	(6 * sum(bsxfun(@minus, J, j0).^2, 1)).^(3/2);

% Compute percentile confidence intervals.
c = (1-confidenceLevel)/2;
p = 100 * normcdf([ ...
	z0 + (z0 + norminv(c))./(1 - a.*(z0+norminv(c))); ...
	z0 + (z0 + norminv(1-c))./(1 - a.*(z0+norminv(1-c)))]);

% Convert to sample-distribution percentiles.
ci = NaN(2,n);
for i = 1:n
	ci(:,i) = prctile(X(:,i), p(:,i), 1);
end

end