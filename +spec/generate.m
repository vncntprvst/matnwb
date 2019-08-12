function generate(namespaceText, schemaSource)
%GENERATE Generates MATLAB classes from namespace mappings.
% optionally, include schema mapping as second argument OR path of specs
% schemaSource is either a path to a directory where the source is
% OR a containers.Map of filenames
Schema = spec.loadSchema();
namespace = spec.schema2matlab(Schema.read(namespaceText));
NamespaceInfo = spec.getNamespaceInfo(namespace);
if ischar(schemaSource)
    schema = containers.Map;
    for i=1:length(NamespaceInfo.filenames)
        filename = NamespaceInfo.filenames{i};
        if ~endsWith(filename, '.yaml')
            filename = [filename '.yaml'];
        end
        fid = fopen(fullfile(schemaSource, filename));
        schema(filename) = fread(fid, '*char') .';
        fclose(fid);
    end
    schema = spec.getSourceInfo(schema);
else % map of schemas with their locations
    schema = spec.getSourceInfo(schemaSource);
end

NamespaceInfo.schema = schema;
namespacePath = 'namespaces';
if 7 ~= exist(namespacePath, 'dir')
    mkdir(namespacePath);
end
cachePath = fullfile(namespacePath, [NamespaceInfo.name '.mat']);
save(cachePath, '-struct', 'NamespaceInfo');

%check/load dependency namespaces
extmap = schemes.loadNamespace(NamespaceInfo.name);

%write files
file.writeNamespace(extmap(NamespaceInfo.name));
end

