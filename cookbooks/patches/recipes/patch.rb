# include_recipe 'base-config::setlocale'
# include_recipe 'base-pkg::install'

vulnerable_packages = []

node_hash = node.normal.to_hash

detections = node_hash["HOST_LIST_VM_DETECTION_OUTPUT"]["RESPONSE"]["HOST_LIST"]["HOST"]["DETECTION_LIST"]["DETECTION"]
severity_level = node_hash["qualys"]["severity_level"]

# List of the packages that are need to be patched
detections.each do |detection|
  if detection["SEVERITY"].to_i >= severity_level.to_i
    packages = detection["RESULTS"].split("\n")
    packages.each do |pkgs|
      unless pkgs.include?("Installed")
        pkg = pkgs.split(" ").select { |p| p.length>0 }
        vulnerable_packages.push("#{pkg[0]}-#{pkg[2]}")
      end
    end
  end
end

vulnerable_packages.each do |pkg|
  package pkg do
    action :install
  end
end
